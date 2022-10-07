import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type BlockIndex = bigint;
export interface ProposalSubmission {
  'url' : string,
  'title' : string,
  'action' : string,
  'knownNeuronName' : string,
  'summary' : string,
  'knownNeuronDescription' : string,
  'motion' : string,
  'knownNeuronID' : bigint,
}
export interface Tokens { 'e8s' : bigint }
export type TransferError = {
    'TxTooOld' : { 'allowed_window_nanos' : bigint }
  } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'TxDuplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TxCreatedInFuture' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type TransferResult = { 'Ok' : BlockIndex } |
  { 'Err' : TransferError };
export interface TransferableNeurons {
  'balance' : ActorMethod<[], bigint>,
  'submitNNSProposal' : ActorMethod<[ProposalSubmission], string>,
  'userInfo' : ActorMethod<[], UserInfo>,
  'withdraw' : ActorMethod<[Array<number>], TransferResult>,
}
export interface UserInfo {
  'principal' : Principal,
  'balance' : bigint,
  'address' : Array<number>,
}
export interface _SERVICE extends TransferableNeurons {}
