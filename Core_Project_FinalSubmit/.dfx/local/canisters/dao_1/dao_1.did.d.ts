import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account { 'owner' : Principal, 'tokens' : Tokens }
export interface DAO {
  'account_balance' : ActorMethod<[], Tokens>,
  'get_all_propsals' : ActorMethod<[], Array<Proposal>>,
  'get_proposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'get_system_params' : ActorMethod<[], SystemParams>,
  'list_accounts' : ActorMethod<[], Array<Account>>,
  'submit_proposal' : ActorMethod<[ProposalPayload], Result_2>,
  'transfer' : ActorMethod<[TransferArgs], Result_1>,
  'update_system_params' : ActorMethod<[UpdateSystemParamsPayload], undefined>,
  'vote' : ActorMethod<[VoteArgs], Result>,
}
export type List = [] | [[Principal, List]];
export interface Proposal {
  'id' : bigint,
  'status' : Proposalstatus,
  'creator' : Principal,
  'votes_no' : Tokens,
  'voters' : List,
  'timestamp' : bigint,
  'votes_yes' : Tokens,
  'payload' : ProposalPayload,
}
export interface ProposalPayload {
  'method' : string,
  'canister_id' : Principal,
  'message' : Uint8Array,
}
export type Proposalstatus = { 'open' : null } |
  { 'rejected' : null } |
  { 'executing' : null } |
  { 'accepted' : null } |
  { 'failed' : string } |
  { 'succeeded' : null };
export type Result = { 'ok' : Proposalstatus } |
  { 'err' : string };
export type Result_1 = { 'ok' : null } |
  { 'err' : string };
export type Result_2 = { 'ok' : bigint } |
  { 'err' : string };
export interface StableStorageStaging {
  'system_params' : SystemParams,
  'accounts' : Array<Account>,
  'proposals' : Array<Proposal>,
}
export interface SystemParams {
  'transfer_fee' : Tokens,
  'proposal_vote_threshold' : Tokens,
  'proposal_submission_deposit' : Tokens,
}
export interface Tokens { 'token_amt' : bigint }
export interface TransferArgs { 'to' : Principal, 'amount' : Tokens }
export interface UpdateSystemParamsPayload {
  'transfer_fee' : [] | [Tokens],
  'proposal_vote_threshold' : [] | [Tokens],
  'proposal_submission_deposit' : [] | [Tokens],
}
export type Vote = { 'no' : null } |
  { 'yes' : null };
export interface VoteArgs { 'vote' : Vote, 'proposal_id' : bigint }
export interface _SERVICE extends DAO {}
