import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Option "mo:base/Option";
import ICRaw "mo:base/ExperimentalInternetComputer";
import Trie "mo:base/Trie";
import List "mo:base/List";
import Error "mo:base/Error";
import Time "mo:base/Time";
import Declaration "./Declaration";
import Debug "mo:base/Debug";

shared actor class DAO(init : Declaration.StableStorageStaging) = Self {
    
    // System Parameters account initialize transfer_fee, proposal_submission_deposti
    //    proposal_vote_threshold
    stable var system_params : Declaration.SystemParams = init.system_params;

    // Accounts List/Trie
    stable var accounts = Declaration.accounts_fromArray(init.accounts);

    // Proposal List/Trie
    stable var proposals = Declaration.proposals_fromArray(init.proposals);

    stable var next_proposal_id : Nat = 0;

    system func heartbeat() : async () {
        await execute_accepted_proposals();
    };


    // get and add to proposal List/Trie
    func proposal_get(id : Nat) : ?Declaration.Proposal = Trie.get(proposals, Declaration.proposal_key(id), Nat.equal);
    func proposal_put(id : Nat, proposal : Declaration.Proposal) {
        proposals := Trie.put(proposals, Declaration.proposal_key(id), Nat.equal, proposal).0;
    };


    // get and add to account List/Trie
    func account_get(id : Principal) : ?Declaration.Tokens = Trie.get(accounts, Declaration.account_key(id), Principal.equal);
    func account_put(id : Principal, tokens : Declaration.Tokens) {
        accounts := Trie.put(accounts, Declaration.account_key(id), Principal.equal, tokens).0;
    };

    // Account List
    public query func list_accounts() : async [Declaration.Account] {
        Iter.toArray(
          Iter.map(Trie.iter(accounts),
                   func ((owner : Principal, tokens : Declaration.Tokens)) : Declaration.Account = { owner; tokens }))
    };

    // Query Caller account balance
    public query({caller}) func account_balance() : async Declaration.Tokens {
        Option.get(account_get(caller), Declaration.zeroToken)
    };

    // Getting current system params
    public query func get_system_params() : async Declaration.SystemParams { system_params };


    // List of proposals 
    public query func get_all_propsals() : async [Declaration.Proposal] {
        Iter.toArray(Iter.map(Trie.iter(proposals), func (kv : (Nat, Declaration.Proposal)) : Declaration.Proposal = kv.1))
    };

    // Query proposal with id. 
    public query func get_proposal(proposal_id: Nat) : async ?Declaration.Proposal {
        proposal_get(proposal_id)
    };



    // Submitting a propsal with payload containing cansiter_id, method name/args and message Blob
    //  Pass in method will be called with args on the cansiter if yes-cote threshold is met.

    public shared({caller}) func submit_proposal(payload: Declaration.ProposalPayload) : async Declaration.Result<Nat, Text> {
        Result.chain(deduct_proposal_submission_deposit(caller), func (()) : Declaration.Result<Nat, Text> {
            let proposal_id = next_proposal_id;
            next_proposal_id += 1;

            let proposal : Declaration.Proposal = {
                id = proposal_id;
                creator = caller;
                payload;
                status = #open;
                votes_yes = Declaration.zeroToken;
                votes_no = Declaration.zeroToken;
                timestamp = Time.now();
                voters = List.nil();
            };
            proposal_put(proposal_id, proposal);
            //Debug.print "VOTE Submit_propsal";
            #ok(proposal_id)
        })
    };


    // Vote on an open proposal
    public shared({caller}) func vote(args: Declaration.VoteArgs) : async Declaration.Result<Declaration.Proposalstatus, Text> {
        switch (proposal_get(args.proposal_id)) {
        case null { #err("No proposal with ID " # debug_show(args.proposal_id) # " exists") };
        case (?proposal) {
                 var status = proposal.status;
                 if (status != #open) {
                     return #err("Proposal " # debug_show(args.proposal_id) # " is not open for voting");
                 };
                 switch (account_get(caller)) {
                 case null { return #err("Caller does not have any tokens to vote with") };
                 case (?{ token_amt = voting_tokens }) {
                          if (List.some(proposal.voters, func (e : Principal) : Bool = e == caller)) {
                              return #err("Already voted");
                          };
                          
                          var votes_yes = proposal.votes_yes.token_amt;
                          var votes_no = proposal.votes_no.token_amt;
                          switch (args.vote) {
                          case (#yes) { votes_yes += voting_tokens };
                          case (#no) { votes_no += voting_tokens };
                          };
                          let voters = List.push(caller, proposal.voters);

                          if (votes_yes >= system_params.proposal_vote_threshold.token_amt) {
                              // Refund the proposal deposit when the proposal is accepted
                              ignore do ? {
                                  let account = account_get(proposal.creator)!;
                                  let refunded = account.token_amt + system_params.proposal_submission_deposit.token_amt;
                                  account_put(proposal.creator, { token_amt = refunded });
                              };
                              status := #accepted;
                          };
                          
                          if (votes_no >= system_params.proposal_vote_threshold.token_amt) {
                              status := #rejected;
                          };

                          let updated_proposal = {
                              id = proposal.id;
                              creator = proposal.creator;
                              payload = proposal.payload;
                              votes_yes = { token_amt = votes_yes };                              
                              votes_no = { token_amt = votes_no };
                              status;
                              timestamp = proposal.timestamp;
                              voters;
                          };
                          proposal_put(args.proposal_id, updated_proposal);
                      };
                 };
                 #ok(status)
             };
        };
    };


 // Transfering Tokens between User accounts   
    public shared({caller}) func transfer(transfer: Declaration.TransferArgs) : async Declaration.Result<(), Text> {
        switch (account_get caller) {
        case null { #err "Caller needs an account to transfer funds" };
        case (?from_tokens) {
                 let fee = system_params.transfer_fee.token_amt;
                 let amount = transfer.amount.token_amt;
                 if (from_tokens.token_amt < amount + fee) {
                     #err ("Caller's account has insufficient funds to transfer " # debug_show(amount));
                 } else {
                     let from_amount : Nat = from_tokens.token_amt - amount - fee;
                     account_put(caller, { token_amt = from_amount });
                     let to_amount = Option.get(account_get(transfer.to), Declaration.zeroToken).token_amt + amount;
                     account_put(transfer.to, { token_amt = to_amount });
                     #ok;
                 };
        };
      };
    };

    // Updating system parameters
    // Callable within proposal execution

    public shared({caller}) func update_system_params(payload: Declaration.UpdateSystemParamsPayload) : async () {
        if (caller != Principal.fromActor(Self)) {
            return;
        };
        system_params := {
            transfer_fee = Option.get(payload.transfer_fee, system_params.transfer_fee);
            proposal_vote_threshold = Option.get(payload.proposal_vote_threshold, system_params.proposal_vote_threshold);
            proposal_submission_deposit = Option.get(payload.proposal_submission_deposit, system_params.proposal_submission_deposit);
        };
    };

    // Deduct from caller acct the token submission deposit
    func deduct_proposal_submission_deposit(caller : Principal) : Declaration.Result<(), Text> {
        switch (account_get(caller)) {
        case null { #err "Caller needs an account to submit a proposal" };
        case (?from_tokens) {
                 let threshold = system_params.proposal_submission_deposit.token_amt;
                 if (from_tokens.token_amt < threshold) {
                     #err ("Caller's account must have at least " # debug_show(threshold) # " to submit a proposal")
                 } else {
                     let from_amount : Nat = from_tokens.token_amt - threshold;
                     account_put(caller, { token_amt = from_amount });
                     #ok
                 };
             };
        };
    };

    // all accepted proposals will be executed with this function call
    func execute_accepted_proposals() : async () {
        let accepted_proposals = Trie.filter(proposals, func (_ : Nat, proposal : Declaration.Proposal) : Bool = proposal.status == #accepted);
        // Update proposal status, before next heartbeat
        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            update_proposal_status(proposal, #executing);
        };

        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            switch (await execute_proposal(proposal)) {
            case (#ok) { update_proposal_status(proposal, #succeeded); };
            case (#err(err)) { update_proposal_status(proposal, #failed(err)); };
            };
        };
    };

    // Executing given proposal
    func execute_proposal(proposal: Declaration.Proposal) : async Declaration.Result<(), Text> {
        try {
            let payload = proposal.payload;
            ignore await ICRaw.call(payload.canister_id, payload.method, payload.message);
            #ok
        }
        catch (e) { #err(Error.message e) };
    };

    func update_proposal_status(proposal: Declaration.Proposal, status: Declaration.Proposalstatus) {
        let updated = {
            status;
            id = proposal.id;
            creator = proposal.creator;
            payload = proposal.payload;
            votes_yes = proposal.votes_yes;
            votes_no = proposal.votes_no;
            voters = proposal.voters;
            timestamp = proposal.timestamp;
        };
        proposal_put(proposal.id, updated);
    };
};
