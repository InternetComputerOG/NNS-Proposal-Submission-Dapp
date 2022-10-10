// ----------- Decription
// This Motoko file contains the logic of our backend canister.

// ----------- Imports

// Imports from Motoko Base Library
import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Buffer       "mo:base/Buffer";
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

// Imports from helpers, utils, & types
import Account      "./Account";
import CRC32        "./CRC32";
import SHA224       "./SHA224";
import T            "types";


// Imports from external interfaces
import LT           "../ledger/ledger";
import GT           "../governance/governance";


shared(init_msg) actor class TransferableNeurons() = this {

    ///////////
    // State //
    ///////////
    private stable var neuronCT : Nat = 0;

    private stable var ownersEntries : [(Nat, Principal)] = [];
    private stable var balancesEntries : [(Principal, Nat)] = [];

    private let owners : HashMap.HashMap<Nat, Principal> = HashMap.fromIter<Nat, Principal>(ownersEntries.vals(), 10, Nat.equal, Hash.hash);
    private let balances : HashMap.HashMap<Principal, Nat> = HashMap.fromIter<Principal, Nat>(balancesEntries.vals(), 10, Principal.equal, Principal.hash);

    ///////////////
    // Constants //
    ///////////////
    // ----------- Configure external actors
    let Ledger = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : LT.Self;
    let Governance = actor "rrkah-fqaaa-aaaaa-aaaaq-cai" : GT.Service;

    // ----------- Declare variables
    let ledger_principal : Principal = Principal.fromActor(Ledger);
    let neuronController: Principal = Principal.fromText("ijeuu-g4z7n-jndij-hzfqh-fe2kw-7oan5-pcmgj-gh3zn-onsas-dqm7c-nqe");
    let proposalFeeAddress: [Nat8] = [213, 219, 82, 55, 159, 197, 32, 220, 48, 234, 161, 122, 174, 117, 119, 181, 236, 125, 167, 133, 216, 0, 60, 24, 116, 75, 190, 151, 166, 138, 121, 53];
    let proposalFee: Nat64 = 1_000_000;
    let icp_fee: Nat64 = 10_000;

    //////////////////////
    // Public Functions //
    //////////////////////
    // ----------- Query Functions
    //
    
   
    // ----------- Call Functions
    // 
    public shared(msg) func userInfo() : async T.UserInfo {
        await getUserInfo(msg.caller);
    };

    public shared(msg) func balance() : async Nat64 {
        await getBalance(msg.caller);
    };

    public shared(msg) func withdraw(account_id : [Nat8]) : async Text {
       await withdrawICP(msg.caller, account_id); 
    };

    public shared(msg) func submitNNSProposal(proposal : T.ProposalSubmission) : async Text {
        await submitProposal(msg.caller, proposal);
    };

    ///////////////////////
    // Private Functions //
    ///////////////////////
    private func getAddress(caller : Principal) : [Nat8] {
        Blob.toArray(Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(caller)));
    };

    private func getSubaccount(caller : Principal) : [Nat8] {
        Blob.toArray(Account.principalToSubaccount(caller));
    };

    private func getUserInfo(caller : Principal) : async T.UserInfo {
        let user_balance = await getBalance(caller);
        return { 
            principal = caller;
            address = getAddress(caller);
            balance = user_balance
            };
    };

    private func getBalance(caller : Principal) : async Nat64 {
        let balance = await Ledger.account_balance({
            account = getAddress(caller)
            });
        return balance.e8s;
    };

    private func withdrawICP(caller: Principal, account_id: [Nat8]) : async Text {
        // get to total amount of ICP the user has
        let user_balance = await getBalance(caller);

        // Transfer amount back to user
        let res = await transferICP(caller, account_id, user_balance);
        return transferResultToText(res);
    };

    private func submitProposal(caller: Principal, proposal: T.ProposalSubmission) : async Text {
        let transferRes: LT.TransferResult = await transferICP(caller, proposalFeeAddress, proposalFee);

        switch(transferRes) {
            case (#Ok(blockIndex)) {
                let returnMessage = "ICP transfer successfully completed in block " # Nat64.toText(blockIndex) # ".";
                let refreshRes = await refreshNeuron();
                
            };
            case (#Err(other)) {
                transferResultToText(transferRes);
            };
        };
    };

    private func transferICP(transferFrom: Principal, transferTo: [Nat8], transferAmount: Nat64) : async LT.TransferResult {
        let res =  await Ledger.transfer({
            memo: Nat64 = 0;
            from_subaccount = ?getSubaccount(transferFrom);
            to = transferTo;
            // the amount of ICP, minus the necessary transaction fee
            amount = { e8s = transferAmount - icp_fee };
            fee = { e8s = icp_fee };
            created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
            });
    };

    private func transferResultToText(result : LT.TransferResult) : Text {
        switch(result) {
            case (#Ok(blockIndex)) {
                "ICP transfer successfully completed in block " # Nat64.toText(blockIndex)
                };
            case (#Err(#InsufficientFunds { balance })) {
                "ICP transaction failed due to insufficient funds."
                };
            case (#Err(other)) {
                "Something went wrong, the ICP transaction was not successful."
                }
        };
    };

    private func refreshNeuron() : async Text {
        let refreshRes = await Governance.claim_or_refresh_neuron_from_account({
            controller = ?neuronController;
            memo = 0;
            });
        switch(refreshRes.result) {
            case (?result) {
                switch (result) {
                    case (#NeuronId(neuronId)) {
                        return "Neuron " # Nat64.toText(neuronId.id) # "was successfully refreshed.";
                    };
                    case (#Error(governanceError)) {
                        return governanceError.error_message;
                    };
                };
            };
            case (null) {
                return "Neuron didn't respond when a balance refresh was attemped.";
            };
        };
    };

    //////////////////////
    // System Functions //
    //////////////////////
    system func preupgrade() {
        ownersEntries := Iter.toArray(owners.entries());
        balancesEntries := Iter.toArray(balances.entries());
    };

    system func postupgrade() {
        ownersEntries := [];
        balancesEntries := [];
    };
};