<script>
    import { onMount } from "svelte";
    import { FontAwesomeIcon } from 'fontawesome-svelte';
    import { auth } from "../store/auth";
    import { toHexString, hexToBytes, principalToAccountDefaultIdentifier, accountIdentifierFromBytes, accountIdentifierToBytes, asciiStringToByteArray } from '../utils/helpers';
    import { AccountIdentifier, LedgerCanister, ICP } from "@dfinity/nns";
    import App from "../App.svelte";
    import Auth from "./Auth.svelte";
    import CanisterIds from "./CanisterIds.svelte";

    // Global variables
    let userPrincipal;
    let userBalance;
    let depositAddress;
    let withdrawalAddress;

    let testNNSPrincipal = "";
    let testNNSNonce = 0;
    let testNNSaccount;

    // UI Flags
    let fetchingUserInfo = true;
    let pendingWithdrawal = false;
    let pendingBalanceRefresh = false;
    let hideWithdrawForm = true;
    let didCopyPrincipal = false;
    let didCopyDepositAddress = false;

    // UI Variables
   

    onMount(async () => {
      if($auth.loggedIn) {
        console.log("Using II for DEX actor");

        fetchUserInfo();
      };
    });

    async function fetchUserInfo() {
      let userInfo = await $auth.actor.userInfo();
      console.log(userInfo);

      userPrincipal = userInfo.principal;
      depositAddress = accountIdentifierFromBytes(userInfo.address);
      userBalance = parseFloat((Number(userInfo.balance) / 100000000).toFixed(4));

      fetchingUserInfo = false;
    };

    async function refreshBalance() {
      pendingBalanceRefresh = true;
      let newBalance = await $auth.actor.balance();
      userBalance = parseFloat((Number(newBalance) / 100000000).toFixed(4));
      pendingBalanceRefresh = false;
    };

    async function withdrawICP(address) {
      pendingWithdrawal = true;
      console.log(address);
      console.log(AccountIdentifier.fromHex(address).bytes);
      let withdrawalResult = await $auth.actor.withdraw(AccountIdentifier.fromHex(address).bytes);
      console.log(withdrawalResult);

      hideWithdrawForm = true;
      pendingWithdrawal = false;
      refreshBalance();
    }

    function copyPrincipal(text) {
        if(window.isSecureContext) {
            didCopyPrincipal = true;
            navigator.clipboard.writeText(text);
        }
        setTimeout(() => {
            didCopyPrincipal = false
        }, 1000)
    };

    function copyDepositAddress(text) {
        if(window.isSecureContext) {
            didCopyDepositAddress = true;
            navigator.clipboard.writeText(text);
        }
        setTimeout(() => {
            didCopyDepositAddress = false
        }, 1000)
    };

    async function fetchNNSAccount(testPrincipal, testNonce) {
      let testAccount = await $auth.actor.generateNNSAccount(testPrincipal, testNonce);
      testNNSaccount = accountIdentifierFromBytes(testAccount);
    };

  </script>
  
  <div class="container">
    {#if fetchingUserInfo}
      <div class="loader"></div> Loading Your Wallet...
    {:else}
      <div class="user-info">
        <h4>Principal</h4>
        {userPrincipal}
        <span class="copy-icon" on:click={() => copyPrincipal(userPrincipal)}>
          <FontAwesomeIcon icon="copy" />
          {#if didCopyPrincipal}
              Copied!
          {/if}
        </span>
      </div>
      <div class="user-info">
        <h4>Deposit Address</h4>
        {depositAddress}
        <span class="copy-icon" on:click={() => copyDepositAddress(depositAddress)}>
          <FontAwesomeIcon icon="copy" />
          {#if didCopyDepositAddress}
              Copied!
          {/if}
        </span>
      </div>
      <div class="user-info">
        <strong>ICP Balance:</strong> 
        {#if pendingBalanceRefresh}
          <div class="loader"></div> Refreshing...
        {:else}
          {userBalance}
        {/if}
        <button on:click={refreshBalance}>Refresh</button>
        <button on:click={() => hideWithdrawForm = !hideWithdrawForm} class:hide={userBalance <= 0.0001}>
          {#if hideWithdrawForm}
            Withdraw
          {:else}
            Hide Form
          {/if}
        </button>
        <div class:hide={hideWithdrawForm}>
          {#if pendingWithdrawal}
            <br/><div class="loader"></div> Processing Your Withdrawal...
          {:else}
            <strong>Withdrawal Address:</strong><br/>
            <input bind:value={withdrawalAddress}><button on:click={withdrawICP(withdrawalAddress)}>Withdraw <strong>{userBalance - 0.0001}</strong> ICP</button>
          {/if}
        </div>
      </div>
    {/if}
    <!-- <input bind:value={testNNSPrincipal}><br/>
    <input type=number bind:value={testNNSNonce}>
    <button on:click={fetchNNSAccount(testNNSPrincipal, testNNSNonce)}></button>
    {testNNSaccount} -->
  </div>
  
  <style>
    .container {
      margin: 30px 0;
      border: 2px solid #fff;
      padding: 15px;
    }

    .hide {
      display: none;
    }

    .user-info {
      margin: 15px;
    }

    .user-info h4 {
      margin-bottom: 5px;
    }

    .copy-icon {
        color: #a9a9a9;
        cursor: pointer;
    }

    .copy-icon:hover {
        color: #d4d4d4;
    }
  </style>