// ----------- Decription
// This Motoko file contains the logic of our backend canister.

// ----------- Imports

// Imports from Motoko Base Library
import Time "mo:base/Time";


module {
    // ----------- return types
    // This is the type used to load the user's info immediately after they log in.
    public type UserInfo = {
        principal : Principal;
        address : [Nat8];
        balance : Nat64;
    }

}