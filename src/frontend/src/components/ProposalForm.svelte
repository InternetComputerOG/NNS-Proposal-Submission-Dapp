<script>
    import { auth } from "../store/auth";
    import { marked } from "marked";
    import { balance } from "../store/balance";

    // Form input values
    let proposal = {
        title: "",
        action: "Motion",
        url: "",
        summary: `## 1. Who I am
Lorem Ipsum

## 2. Objective
Lorem Ipsum

## 3. Background
Lorem Ipsum

## 4. Why this is important
Lorem Ipsum

## 5. Pros
Lorem Ipsum

## 6. Cons
Lorem Ipsum

## 7. Key milestones (if any)
Lorem Ipsum

## 8. Discussion leads (if any)
Alice, Bob, etc...

## 9. Security concerns (if any)
Lorem Ipsum

## 10. What we are asking the community

* Review comments, ask questions, give feedback

* Vote accept or reject on NNS Motion or Known Neuron Registration

Developer forum URL: https://forum.dfinity.org/t/long-term-r-d-tokenomics-proposal/9392/3`,
        motion: "",
        knownNeuronID: 0,
        knownNeuronName: "",
        knownNeuronDescription: ""
    };

    let proposalActionOptions = [
        'Motion',
        'Register Known Neuron'
    ];

    // Other Variables
    let errorHighlight = {
        title: false,
        url: false,
        summary: false,
        knownNeuronID: false,
        knownNeuronName: false,
        knownNeuronDescription: false,
    };
    let canSubmitError = "";
    let formSubmitted = false;
    let pendingSubmit = false;
    let resultMessage = "";
    let disclaimer = `
---
> ### Disclaimer
> This proposal was submitted using the NN Proposal Submission Dapp created by [Isaac Valadez](https://isaac.icp.page/).
> - Website: [nnsproposal.icp.xyz](https://nnsproposal.icp.xyz/) or [uf2fn-liaaa-aaaal-abeba-cai.ic0.app](https://uf2fn-liaaa-aaaal-abeba-cai.ic0.app/)
> - GitHub: [github.com/InternetComputerOG/NNS-Proposal-Submission-Dapp](https://github.com/InternetComputerOG/NNS-Proposal-Submission-Dapp)
> 
> Anyone can use this Dapp to submit a proposal by filling out the form and paying a fee, so the source of this proposal cannot be verified. Please keep this in mind and vote responsibly.
---
`;

    async function submitProposal(proposal) {
        console.log(proposal);
        formSubmitted = true;
        pendingSubmit = true;

        let result = await $auth.actor.submitNNSProposal(proposal);
        console.log(result);
        resultMessage = result;


        pendingSubmit = false;
    };

    function canSubmit(balance, proposal) {
        canSubmitError = "";
        errorHighlight = {
            title: false,
            url: false,
            summary: false,
            knownNeuronID: false,
            knownNeuronName: false,
            knownNeuronDescription: false,
        };

        if (balance < 0.12) {
            canSubmitError = "*not enough ICP";
            return false;

        } else if (proposal.title == "") {
            canSubmitError = "*you need to add a title to your proposal";
            errorHighlight.title = true;
            return false;

        } else if (proposal.url == "") {
            canSubmitError = "*you need to add a URL to your proposal";
            errorHighlight.url = true;
            return false;

        } else if (proposal.summary == "") {
            canSubmitError = "*you need to add a Summary to your proposal";
            errorHighlight.summary = true;
            return false;

        } else if (proposal.action == "Register Known Neuron") {
            if (proposal.knownNeuronID == "") {
                canSubmitError = "*you need to add a Known Neuron ID to your proposal";
                errorHighlight.knownNeuronID = true;
                return false;
            } else if (proposal.knownNeuronName == "") {
                canSubmitError = "*you need to add a Known Neuron Name to your proposal";
                errorHighlight.knownNeuronName = true;
                return false;
            } 
        }

        return true;
    };


</script>
  
<div class="proposal-form">
    <h2>Submit A New Proposal To The NNS</h2>
    The 10 ICP fee is sent to the dapp's neuron (<a href="https://dashboard.internetcomputer.org/neuron/9383571398983269667" target="_blank">9383571398983269667</a>) to cover the 10 ICP burn penalty that will be applied if your proposal gets rejected. This ICP is locked into the neuron, so even if your proposal is adopted you cannot be refunded. Maturity from this neuron is used to provide the cycles and maintenance needed to keep this service available.
    <br/><br/>
    This dapp makes submitting NNS proposals easy for non-technical users with the lowest cost possible. If you'd like to learn how to re-create this interface using a neuron that you control, check out the code on <a href="https://github.com/InternetComputerOG/NNS-Proposal-Submission-Dapp" target="_blank">GitHub</a>.
    <h4>Title</h4>
    <input bind:value={proposal.title} class:error-highlight={errorHighlight.title}>
    
    <h4>Type</h4>
    {#each proposalActionOptions as option}
        <label>
            <input type=radio bind:group={proposal.action} name="proposalAction" value={option}>
            {option}
        </label><br/>
    {/each}
    
    <h4>URL</h4>
    <input bind:value={proposal.url} class:error-highlight={errorHighlight.url}>
    
    <h4>Summary</h4>
    You can style/format using <a href="https://www.markdownguide.org/cheat-sheet/" target="_blank">Markdown</a>.
    <textarea bind:value={proposal.summary} rows="20" cols="50" class:error-highlight={errorHighlight.summary}></textarea>

    {#if proposal.action == "Motion"}
        <h4>Motion Text</h4>
        <input bind:value={proposal.motion}>
    {:else if proposal.action == "Register Known Neuron"}
        <h4>Known Neuron ID</h4>
        <input type=number bind:value={proposal.knownNeuronID} class:error-highlight={errorHighlight.knownNeuronID}>

        <h4>Known Neuron Name</h4>
        <input bind:value={proposal.knownNeuronName} class:error-highlight={errorHighlight.knownNeuronName}>

        <h4>Known Neuron Description</h4>
        <input bind:value={proposal.knownNeuronDescription}>
    {/if}

    <button class="proposal-submit-btn" on:click={submitProposal(proposal)} disabled={!canSubmit($balance.ICP, proposal)}>Submit Proposal</button>
    <br/>
    {#if $balance.ICP < 12}
        You need to deposit {parseFloat(12 - $balance.ICP).toFixed(4)} ICP to submit a Proposal.
    {:else if $balance.ICP >= 12}
        You will have {parseFloat($balance.ICP - 12).toFixed(4)} ICP left after submitting a Proposal.
    {/if}
    <h6 class="pre-submit-error-message">{canSubmitError}</h6>
    {#if formSubmitted}
        <div class="submission-result">
            {#if pendingSubmit}
                <div class="loader"></div> Submitting your proposal...
            {:else}
                {resultMessage}
            {/if}
        </div>
    {/if}
    
</div>
<div class="proposal-preview">
    <h2>Proposal Preview</h2>
    {@html marked(
        "# " + proposal.title + " | " + proposal.action + " (nnsproposal.icp.xyz)" + disclaimer + proposal.summary
    )}
</div>

<style>
    .proposal-form, .proposal-preview, .submission-result {
        padding: 3%;
        max-width: 35%;
        margin: 4%;
        text-align: left;
        display: inline-block;
        vertical-align: top;
    }

    .proposal-form h4 {
        margin: 2em 0 0.5em;
    }

    .proposal-form > input, .proposal-form textarea {
        padding: 12px;
        width: 100%;
        border-radius: 6px;
    }

    .proposal-preview, .submission-result {
        border: 2px solid #fff;
    }

    .proposal-preview > :first-child {
        font-style: italic;
        text-align: center;
        line-height: 50px;
        border-top: 2px dotted white;
        border-bottom: 2px dotted white;
    }

    .error-highlight {
        border: 2px solid red;
        background-color: #FFF9A6;
    }

    .pre-submit-error-message {
        color: red;
        font-weight: bold;
    }

    .proposal-submit-btn {
        margin-top: 25px;
        margin-left: 0px;
    }

    .submission-result {
        max-width: 80%;
    }

    @media (max-width: 640px) {
        .proposal-form, .proposal-preview {
            padding: 3%;
            max-width: 80%;
        }
    }
</style>