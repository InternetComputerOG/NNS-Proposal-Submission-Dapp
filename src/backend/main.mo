//  ----------- Decription
//  This Motoko file contains the logic of our backend canister.

//  ----------- Imports

//  Imports from Motoko Base Library
import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Buffer       "mo:base/Buffer";
import Bool         "mo:base/Buffer";
import Char         "mo:base/Char";
import Debug        "mo:base/Debug";
import Hash         "mo:base/Hash";
import HashMap      "mo:base/HashMap";
import Int          "mo:base/Int";
import Iter         "mo:base/Iter";
import Nat          "mo:base/Nat";
import Nat8         "mo:base/Nat8";
import Nat32        "mo:base/Nat32";
import Nat64        "mo:base/Nat64";
import Principal    "mo:base/Principal";
import Text         "mo:base/Text";
import Time         "mo:base/Time";

//  Imports from helpers, utils, & types
import Account      "lib/Account";
import CRC32        "lib/CRC32";
import Helpers      "./helpers";
import SHA224       "lib/SHA224";
import T            "types";


//  Imports from external interfaces
import LT           "../ledger/ledger";
import GT           "../governance/governance";

shared actor class NNSProposal() = this {

  ///////////
  // State //
  ///////////
  //  This dapp does not require any state variables.  
  
  ///////////////
  // Constants //
  ///////////////
  //  ----------- Configure external actors
  let Ledger = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : LT.Self;
  let Governance = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : GT.Service;

  //  ----------- Neuron variables
  let neuronId : GT.NeuronId = { 
    id : Nat64 = 9383571398983269667;
  };
  
  let neuronController : Principal = Principal.fromText(
    "ijeuu-g4z7n-jndij-hzfqh-fe2kw-7oan5-pcmgj-gh3zn-onsas-dqm7c-nqe"
  );

  //  Find this by funding a neuron and then searching for the transaction 
  //  here: https://dashboard.internetcomputer.org/transactions
  //  WARNING: Be sure to use a string with only uppercase letters!
  let neuronDepositAddress : [Nat8] = Helpers.accountIdenfifierFromText(
    "D5DB52379FC520DC30EAA17AAE7577B5EC7DA785D8003C18744BBE97A68A7935"
  );

  //  This declares a multi-line string of text that's formatted in Markdown, to be added 
  //  to the summary of every proposal submission.
  let newLine : Text = Char.toText(Char.fromNat32(10));
  var disclaimer : Text = newLine # newLine;
  disclaimer #= "--- " # newLine;
  disclaimer #= "> ### Disclaimer" # newLine;
  disclaimer #= "> This proposal was submitted using the NNS Proposal Submission Dapp. ";
  disclaimer #= "Anyone can use this Dapp to submit a proposal by filling out the form ";
  disclaimer #= "and paying a fee, so the source of this proposal cannot be verified. ";
  disclaimer #= "Please keep this in mind and vote responsibly." # newLine;
  disclaimer #= "> - Website: [nnsproposal.icp.xyz](https://nnsproposal.icp.xyz/) or ";
  disclaimer #= "[uf2fn-liaaa-aaaal-abeba-cai.ic0.app](https://uf2fn-liaaa-aaaal-abeba-cai.ic0.app/)" # newLine;
  disclaimer #= "> - GitHub: [github.com/InternetComputerOG/NNS-Proposal-Submission-Dapp]";
  disclaimer #= "(https://github.com/InternetComputerOG/NNS-Proposal-Submission-Dapp)" # newLine;
  disclaimer #= "> - Created by [Isaac](https://isaac.icp.page/)." # newLine;
  disclaimer #= "--- " # newLine # newLine;

  //  ----------- Transaction variables
  let ledger_principal : Principal = Principal.fromActor(Ledger);
  let proposalFee : Nat64 = 1_000_000_000;
  let icp_fee : Nat64 = 10_000;

  //////////////////////
  // Public Functions //
  //////////////////////
  //  ----------- Call Functions
  public shared({ caller }) func userInfo() : async T.UserInfo {
    await getUserInfo(caller);
  };

  public shared({ caller }) func balance() : async Nat64 {
    await getBalance(caller);
  };

  public shared({ caller }) func withdraw(account_id : [Nat8]) : async LT.TransferResult {
    await withdrawICP(
      caller, 
      account_id
    ); 
  };

  public shared({ caller }) func submitNNSProposal(proposal : T.ProposalSubmission) : async T.SubmissionResult {
    await submitProposal(
      caller, 
      proposal
    );
  };

  ///////////////////////
  // Private Functions //
  ///////////////////////
  //  ----------- Functions called directly by the public functions
  private func getUserInfo(caller : Principal) : async T.UserInfo {
    let user_balance = await getBalance(caller);

    return { 
      principal = caller;
      address = Helpers.getAddress(
        Principal.fromActor(this), 
        caller
      );
      balance = user_balance
    };
  };

  private func getBalance(caller : Principal) : async Nat64 {
    let balance = await Ledger.account_balance({
      account = Helpers.getAddress(
        Principal.fromActor(this), 
        caller
      );
    });

    return balance.e8s;
  };

  private func withdrawICP(
    caller : Principal, 
    account_id : [Nat8] 
    ) : async LT.TransferResult {
      //  Get to total amount of ICP the user has
      let user_balance = await getBalance(caller);

      //  Transfer that amount back to user
      await transferICP(
        caller, 
        account_id, 
        user_balance
      );
  };

  private func submitProposal(
    caller : Principal, 
    proposal : T.ProposalSubmission
    ) : async T.SubmissionResult {

      //  Try to send ICP to the Neuron
      let transferResult: LT.TransferResult = await transferICP(
        caller, 
        neuronDepositAddress, 
        proposalFee
      );

      switch (transferResult) {

        //  ICP transaction successful
        case (#Ok(blockIndex)) {

          //  Try to refesh the Neuron
          let refreshResult = await refreshNeuron();
          
          switch (refreshResult) {

            //  Neuron refresh successful
            case (#NeuronId(refreshResponse)) {

              //  Try to make the proposal
              let proposalResult = await makeProposal(proposal);

              switch (proposalResult) {

                // Proposal submission successful
                case (#MakeProposal(proposalResponse)) {

                  switch (proposalResponse.proposal_id) {

                    // Send the Ok result
                    case (?proposalId) {
                      #Ok({
                        block = blockIndex;
                        proposalId = proposalId.id;
                      });
                    };
                    case _ {
                      #Ok({
                        block = blockIndex;
                        proposalId = 0;
                      });
                    };
                  };
                };

                // Proposal submission failed, send error
                case _ {
                  #Err({
                    reason = "ERROR3";
                  });
                };
              };
            };

            //  Neuron refresh failed, send error
            case (#Error(refreshError)) {
              #Err({
                reason = "ERROR2";
              });
            };
          };
        };

        //  ICP transaction failed, send error
        case (#Err(transferError)) {
          #Err({
            reason = "ERROR1";
          });
        };
      };
  };

  //  ----------- ICP Ledger & Transaction Functions
  private func transferICP(
    transferFrom : Principal, 
    transferTo : [Nat8], 
    transferAmount : Nat64
    ) : async LT.TransferResult {
      let res =  await Ledger.transfer({
        memo: Nat64 = 0;
        from_subaccount = ?Helpers.getSubaccount(transferFrom);
        to = transferTo;
        //  The amount of ICP, minus the necessary transaction fee
        amount = { e8s = transferAmount - icp_fee };
        fee = { e8s = icp_fee };
        created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
      });
  };

  //  ----------- NNS & Proposal Functions
  private func refreshNeuron() : async GT.Result_1 {
    let refreshResult = await Governance.claim_or_refresh_neuron_from_account({
      controller = ?neuronController;
      memo = 0;
    });

    switch (refreshResult.result) {
      case (?response) {
        response;
      };
      case _ {
        #Error{
          error_message = "Unreachable";
          error_type = 0;
        };
      };
    };
  };

  private func makeProposal (proposal : T.ProposalSubmission) : async GT.Command_1 {
    let proposalAction = createAction(proposal);
    let proposalTitle = proposal.action # " | " # proposal.title # " (nnsproposal.icp.xyz)";
    let proposalSummary = proposal.summary # disclaimer;

    let makeProposalCommand: GT.Command = #MakeProposal({
      url = proposal.url;
      title = ?proposalTitle;
      action = ?proposalAction;
      summary = proposalSummary;
    });

    let result = await Governance.manage_neuron({
      id = ?neuronId;
      command = ?makeProposalCommand;
      neuron_id_or_subaccount = null;
    });

    switch (result.command) {
      case (?response) {
        response;
      };
      case _ {
        #Error{
          error_message = "Unreachable";
          error_type = 0;
        };
      };
    };
  };

  private func createAction(proposal : T.ProposalSubmission) : GT.Action {
    switch (proposal.action) {
      case ("Register Known Neuron") {
        #RegisterKnownNeuron {
          id = ?{ 
            id = Nat64.fromNat(proposal.knownNeuronID);
          };
          known_neuron_data = ?{
            name = proposal.knownNeuronName;
            description = ?proposal.knownNeuronDescription;
          };
        };
      };
      case _ {
        #Motion({
          motion_text = proposal.motion;
        });
      };
    };
  };

  //////////////////////
  // System Functions //
  //////////////////////
  //  This dapp doesn't not need or use any system functions so these are commented out. 
  //  If this app did have state, these functions could be be used to store and retrieve 
  //  state data from stable memory before and after an upgrade.
  //
  //  system func preupgrade() {
  //  };
  //
  //  system func postupgrade() {
  //  };
};