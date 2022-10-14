//  ----------- Decription
//  This Motoko file contains the custom types we need for our main.mo logic.

//  ----------- Imports

//  Imports from Motoko Base Library
import Time         "mo:base/Time";
import Nat64        "mo:base/Nat64";

//  Imports from helpers, utils, & types
import LT           "../ledger/ledger";

module {
  //  ----------- return types
  //  This is the type used to load the user's info immediately after they log in.
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

  public type SubmissionResult = {
    #Ok : SubmissionResponse;
    #Err : SubmissionError;
  };

  public type SubmissionResponse = {
    block : Nat64;
    proposalId : Nat64;
  };

  public type SubmissionError = {
    reason : Text;
  }
}