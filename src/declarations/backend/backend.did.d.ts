import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

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
export interface TransferableNeurons {
  'balance' : ActorMethod<[], bigint>,
  'submitNNSProposal' : ActorMethod<[ProposalSubmission], string>,
  'userInfo' : ActorMethod<[], UserInfo>,
  'withdraw' : ActorMethod<[Array<number>], string>,
}
export interface UserInfo {
  'principal' : Principal,
  'balance' : bigint,
  'address' : Array<number>,
}
export interface _SERVICE extends TransferableNeurons {}
