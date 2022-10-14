<script>
  import { AuthClient } from "@dfinity/auth-client";
  import { onMount } from "svelte";
  import { auth, createActor } from "../store/auth";

  let client;

  onMount(async () => {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      handleAuth();
    }
  });

  function handleAuth() {
    auth.update(() => ({
      loggedIn: true,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));
  }

  function login() {
    client.login({
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:8000/#authorize`,
      onSuccess: handleAuth,
    });
  }

  async function logout() {
    await client.logout();
    auth.update(() => ({
      loggedIn: false,
      actor: createActor(),
    }));
  }
</script>

<div class="container">
  {#if $auth.loggedIn}
    <div>
      <button on:click={logout}>Log out</button>
    </div>
  {:else}
    <button on:click={login}>Authenticate in with Internet Identity</button>
  {/if}
</div>

<style>
  .container {
    margin: 30px 0;
  }
</style>
