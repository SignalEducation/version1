<template>
    <div>
        <p>
       
        </p>
         <fieldset>
             <label>Title</label>
            <input v-model="cbeTitle">
         </fieldset>

          <fieldset>
             <label>Name</label>
            <input v-model="cbeName">
         </fieldset>

        <fieldset>
            <label>Description</label>
            <input v-model="cbeDescription">
         </fieldset>

        <fieldset>
            <label>Time Limit</label>
            <input v-model="cbeTimeLimit">
         </fieldset>

        <fieldset>
            <label>Number of allowable pauses</label>
            <input v-model="cbeNumberOfPausesAllowed">
         </fieldset>

        <fieldset>
            <label>Number of allowable pauses</label>
            <input v-model="cbeLengthOfEachPause" >
         </fieldset>   



    </div>
</template>

<script>
    export default {
        
    }
</script>

<style lang="scss" scoped>

</style>
