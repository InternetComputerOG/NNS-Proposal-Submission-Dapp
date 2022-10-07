// ----------- Decription
// This Motoko file contains the custom types we need for our main.mo logic.

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
    };

    public type ProposalSubmission = {
        title : Text;
        action : Text;
        url : Text;
        summary : Text;
        motion : Text;
        knownNeuronID : Nat;
        knownNeuronName : Text;
        knownNeuronDescription : Text;
    };

}