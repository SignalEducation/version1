<template>
    <div>         
         <ul id="cbe-details-list">
            <li class="cbe-detail">        
                <fieldset>
                    <label>Title</label>
                    <input v-model="cbeTitle">
                </fieldset>
            </li>
             <li class="cbe-detail">
                <fieldset>
                    <label>Name</label>
                    <input v-model="cbeName">
                </fieldset>
             </li>
             <li class="cbe-detail">
                <fieldset>
                    <label>Description</label>
                    <input v-model="cbeDescription">
                </fieldset>                 
             </li>
             <li class="cbe-detail">
                <fieldset>
                    <label>Time Limit</label>
                    <input v-model="cbeTimeLimit">
                </fieldset>
             </li>
             <li class="cbe-detail">
                <fieldset>
                    <label>Number of allowable pauses</label>
                    <input v-model="cbeNumberOfPausesAllowed">
                </fieldset>                 
             </li>
             <li class="cbe-detail">
                <fieldset>
                    <label>Number of allowable pauses</label>
                    <input v-model="cbeLengthOfEachPause" >
                </fieldset>   
             </li>
         </ul>
    </div>
</template>

<script>
    export default {
        
    }
</script>

<style lang="scss" scoped>

</style>
