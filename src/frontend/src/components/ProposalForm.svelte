<script>
    import { auth } from "../store/auth";
    import { marked } from "marked";

    // Form input values
    let proposalTitle = "";
    let proposalTypeOptions = [
        'Motion',
        'Register Known Neuron'
    ];
    let proposalType = "";
    let proposalURL = "";
    let proposalSummary = "";
    let proposalMotion = "";
    let proposalKnownNeuronID = 0;
    let proposalKnownNeuronName = "";
    let proposalKnownNeuronDescription = "";
</script>
  
<div class="container">
    <h2>Submit A New Proposal To The NNS</h2>
    The 12 ICP fee covers the 10 ICP burn penalty if your proposal gets rejected, with any remaining amount contributing to the cycles and time needed to maintain this interface.
    
    <h4>Title</h4>
    <input bind:value={proposalTitle}>
    
    <h4>Type</h4>
    {#each proposalTypeOptions as option}
        <label>
            <input type=radio bind:group={proposalType} name="proposalType" value={option}>
            {option}
        </label>
    {/each}
    
    <h4>URL</h4>
    <input bind:value={proposalURL}>
    
    <h4>Summary</h4>
    <textarea bind:value={proposalSummary}></textarea>
    <h4>Title</h4>
    <input bind:value={proposalTitle}>
    <h4>Title</h4>
    <input bind:value={proposalTitle}>
    <h4>Title</h4>
    <input bind:value={proposalTitle}>
    <h4>Title</h4>
    <input bind:value={proposalTitle}>

    <h2>Preview</h2>
    {@html marked(proposalSummary)}
</div>

<style>

</style>