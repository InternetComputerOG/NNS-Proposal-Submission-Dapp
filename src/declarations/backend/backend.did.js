export const idlFactory = ({ IDL }) => {
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
  const TransferableNeurons = IDL.Service({
    'balance' : IDL.Func([], [IDL.Nat64], []),
    'generateNNSAccount' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(IDL.Nat8)],
        [],
      ),
    'userInfo' : IDL.Func([], [UserInfo], []),
    'withdraw' : IDL.Func([IDL.Vec(IDL.Nat8)], [TransferResult], []),
  });
  return TransferableNeurons;
};
export const init = ({ IDL }) => { return []; };
