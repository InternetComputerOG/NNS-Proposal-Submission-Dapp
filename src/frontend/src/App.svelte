<script>
  import Auth from "./components/Auth.svelte";
  import { auth } from "./store/auth";
  import { library } from '@fortawesome/fontawesome-svg-core';
  import { faCopy } from '@fortawesome/free-solid-svg-icons';
  import CanisterIds from "./components/CanisterIds.svelte";
  import Wallet from "./components/Wallet.svelte";
  import ProposalForm from "./components/ProposalForm.svelte";
  import Links from "./components/Links.svelte";

  // Add fontawesome icons
  const icons = [faCopy];
  library.add(icons);
</script>

<main>
  <div class="container">
    <a
      href="https://dfinity.org"
      target="_blank"
      rel="noopener noreferrer"
      class="logo"
    >
      <img src="images/dfinity.svg" alt="DFINITY logo" />
    </a>
    <h1>NNS Proposal Submission dApp</h1>
    <Auth />
  </div>
  {#if $auth.loggedIn}
    <Wallet />
    <ProposalForm />
  {/if}
  <div class="container">
    <Links />
    <CanisterIds />
  </div>
</main>

<style>
  img {
    height: 22px;
  }
  .logo {
    display: inline-block;
    margin-bottom: 64px;
    margin-top: 24px;
  }

  main {
    text-align: center;
    padding: 1em;
  }

  h1 {
    text-transform: uppercase;
    font-size: 3em;
    font-weight: 400;
    line-height: 1.09;
  }

  @media (min-width: 640px) {
    .container {
      max-width: 800px;
      margin: 0 auto;
    }
    h1 {
      font-size: 4em;
    }
  }
</style>
