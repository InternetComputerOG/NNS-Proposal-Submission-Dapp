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
  const UserInfo = IDL.Record({
    'principal' : IDL.Principal,
    'balance' : IDL.Nat64,
    'address' : IDL.Vec(IDL.Nat8),
  });
  const TransferableNeurons = IDL.Service({
    'balance' : IDL.Func([], [IDL.Nat64], []),
    'submitNNSProposal' : IDL.Func([ProposalSubmission], [IDL.Text], []),
    'userInfo' : IDL.Func([], [UserInfo], []),
    'withdraw' : IDL.Func([IDL.Vec(IDL.Nat8)], [IDL.Text], []),
  });
  return TransferableNeurons;
};
export const init = ({ IDL }) => { return []; };
