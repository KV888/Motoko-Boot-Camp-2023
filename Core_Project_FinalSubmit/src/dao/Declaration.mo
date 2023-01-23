import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Trie "mo:base/Trie";
import List "mo:base/List";

module {
  public type Tokens = { token_amt : Nat };

  public let token_threshold = { token_amt = 100 };
  
  public let initToken = { token_amt = 0 };  
  
  public type Vote = { #no; #yes };

  public type VoteArgs = { vote : Vote; proposal_id : Nat };

  public type Result<T, E> = Result.Result<T, E>;

  public type Account = { owner : Principal; tokens : Tokens };

  public type Proposal = {
    id : Nat;
    creator : Principal;
    payload : ProposalPayload;
    status : Proposalstatus;
    votes_yes : Tokens;
    votes_no : Tokens;
    timestamp : Int;
    voters : List.List<Principal>;
  };

  public type ProposalPayload = {
    method : Text;
    canister_id : Principal;
    message : Blob;
  };

  public type Proposalstatus = {
      #accepted ;  // "yes" votes reached threshold to pass the proposal, waiting to be executed
      #open;  // The proposal still open for voting
      #failed : Text;   // The proposal failed during executing 
      #executing;
      #rejected;  // "no" votes reached threshold to reject the proposal, waiting to be executed
      #succeeded;  // Successfully executed proposal
  };

  public type TransferArgs = { to : Principal; amount : Tokens };

  public type UpdateSystemParamsPayload = {
    transfer_fee : ?Tokens;
    proposal_vote_threshold : ?Tokens;
    proposal_submission_deposit : ?Tokens;
  };

  public type SystemParams = {
    transfer_fee: Tokens;

    // Token Amt hold from user account submitting a proposal. Will be deducted from User unless 
    //   proposal is accepted to prevent attacks or spamming.
  
    proposal_submission_deposit: Tokens;

    // Token Threshold needed to pass or reject a proposal
    proposal_vote_threshold: Tokens;
  };

  public type StableStorageStaging = {
    accounts: [Account];
    proposals: [Proposal];
    system_params: SystemParams;
  };


  // getting account key

  public func account_key(t: Principal) : Trie.Key<Principal> = { key = t; hash = Principal.hash t };

  // Note...Int.hash depricated warning but should run

  public func proposal_key(t: Nat) : Trie.Key<Nat> = { key = t; hash = Int.hash t };
  

// Proposal Trie from Array
  
  public func proposals_fromArray(arr: [Proposal]) : Trie.Trie<Nat, Proposal> {
      var s = Trie.empty<Nat, Proposal>();
      for (proposal in arr.vals()) {
          s := Trie.put(s, proposal_key(proposal.id), Nat.equal, proposal).0;
      };
      s
  };
  

  // Accounts Trie from Array

  public func accounts_fromArray(arr: [Account]) : Trie.Trie<Principal, Tokens> {
      var s = Trie.empty<Principal, Tokens>();
      for (account in arr.vals()) {
          s := Trie.put(s, account_key(account.owner), Principal.equal, account.tokens).0;
      };
      s
  };


  
}
