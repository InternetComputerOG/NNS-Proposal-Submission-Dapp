//  ----------- Decription
//  This Motoko file contains simple functions that needed for main.mo.

//  ----------- Imports

//  Imports from Motoko Base Library
import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Hash         "mo:base/Hash";
import Principal    "mo:base/Principal";
import Result       "mo:base/Result";
import Text         "mo:base/Text";

//  Imports from helpers, utils, & types
import Account      "lib/Account";
import Hex          "lib/Hex";

module {

  //  Takes a string representing an AccountIdentifier (including the prefix) and converts it into [Nat8]
  public func accountIdenfifierFromText(accountId : Text) : [Nat8] {
    switch (Hex.decode(accountId)) {
      case (#err(e)) { [0] };
      case (#ok(result)) {
        result;
      };
    };
  };

  //  Takes the principal of a canister and finds the AccountIdentifier (as Nat8) which 
  //  corresponds to the Principal of a caller.
  public func getAddress(
    canister_p : Principal, 
    caller_p : Principal
    ) : [Nat8] {
      Blob.toArray(Account.accountIdentifier(canister_p, Account.principalToSubaccount(caller_p)));
  };

  public func getSubaccount(caller : Principal) : [Nat8] {
    Blob.toArray(Account.principalToSubaccount(caller));
  };

  // Drops the first 'n' elements of an array, returns the remainder of that array.
  public func drop<T>(
    xs : [T], 
    n : Nat
    ) : [T] {
      let xS = xs.size();
      if (xS <= n) return [];
      let s = xS - n : Nat;
      Array.tabulate<T>(s, func (i : Nat) : T { xs[n + i]; });
  };
};