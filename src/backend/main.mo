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

    public shared(msg) func withdraw(account_id : [Nat8]) : async LT.TransferResult {
       await withdrawICP(msg.caller, account_id); 
    };

    public shared(msg) func submitNNSProposal(proposal : T.ProposalSubmission) : async Text {
        await submitProposal(proposal);
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

    private func withdrawICP(caller: Principal, account_id: [Nat8]) : async LT.TransferResult {
        // get to total amount of ICP the user has
        let user_balance = await getBalance(caller);

        // Transfer amount back to user
        let icp_reciept =  await Ledger.transfer({
            memo: Nat64 = 0;
            from_subaccount = ?getSubaccount(caller);
            to = account_id;
            // the amount to the total amount of ICP they have, minus the necessary transaction fee
            amount = { e8s = user_balance - icp_fee };
            fee = { e8s = icp_fee };
            created_at_time = ?{ timestamp_nanos = Nat64.fromNat(Int.abs(Time.now())) };
        });
    };

    private func submitProposal(proposal: T.ProposalSubmission) : async Text {
        return "Test!";
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