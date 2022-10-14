export const idlFactory = ({ IDL }) => {
  const ProposalSubmission = IDL.Record({
    'url' : IDL.Text,
    'title' : IDL.Text,
    'action' : IDL.Text,
    'knownNeuronName' : IDL.Text,
    'summary' : IDL.Text,
    'knownNeuronDescription' : IDL.Text,
    'motion' : IDL.Text,
    'knownNeuronID' : IDL.Nat,
  });
  const SubmissionResponse = IDL.Record({
    'block' : IDL.Nat64,
    'proposalId' : IDL.Nat64,
  });
  const SubmissionError = IDL.Record({ 'reason' : IDL.Text });
  const SubmissionResult = IDL.Variant({
    'Ok' : SubmissionResponse,
    'Err' : SubmissionError,
  });
  const UserInfo = IDL.Record({
    'principal' : IDL.Principal,
    'balance' : IDL.Nat64,
    'address' : IDL.Vec(IDL.Nat8),
  });
  const BlockIndex = IDL.Nat64;
  const Tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const TransferError = IDL.Variant({
    'TxTooOld' : IDL.Record({ 'allowed_window_nanos' : IDL.Nat64 }),
    'BadFee' : IDL.Record({ 'expected_fee' : Tokens }),
    'TxDuplicate' : IDL.Record({ 'duplicate_of' : BlockIndex }),
    'TxCreatedInFuture' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Tokens }),
  });
  const TransferResult = IDL.Variant({
    'Ok' : BlockIndex,
    'Err' : TransferError,
  });
  const NNSProposal = IDL.Service({
    'balance' : IDL.Func([], [IDL.Nat64], []),
    'submitNNSProposal' : IDL.Func(
        [ProposalSubmission],
        [SubmissionResult],
        [],
      ),
    'userInfo' : IDL.Func([], [UserInfo], []),
    'withdraw' : IDL.Func([IDL.Vec(IDL.Nat8)], [TransferResult], []),
  });
  return NNSProposal;
};
export const init = ({ IDL }) => { return []; };
