<template>
    <div class="form-row align-items-left col-lg-10 ml-1">   

  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Name</label>
    <div class="ml-4">
      <input v-model="cbeName"  class="form-control ml-5" id="colFormLabel" placeholder="Name">
    </div>
  </div>

  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Title</label>
    <div class="ml-4">
      <input  v-model="cbeTitle" class="form-control ml-5" id="colFormLabel" placeholder="Title">
    </div>
  </div>
      
  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Description</label>
    <div class="ml-4">
      <input v-model="cbeDescription" class="form-control ml-5" id="colFormLabel" placeholder="Description">
    </div>
  </div>
      
  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Time</label>
    <div class="ml-4">
      <input v-model="cbeTimeLimit" class="form-control ml-5" id="colFormLabel" placeholder="Time Limit">
    </div>
  </div>

  <div class="form-group row">
    <label for="colFormLabel" class="col-sm-2 col-form-label">Pauses</label>
    <div class="ml-4">
      <input v-model="cbeNumberOfPauses" class="form-control ml-5" id="colFormLabel" placeholder="Pauses">
    </div>
  </div>

    <div class="form-group row">
    <label for="colFormLabel" class="col-sm-2 col-form-label">Length</label>
    <div class="ml-4">
      <input v-model="cbeLengthOfPauses" class="form-control ml-5" id="colFormLabel" placeholder="Length of pauses">
    </div>
  </div>
      
       
    </div>
</template>

<script>
    export default {
                data: function () {
                    return {
                        cbeName: null,
                        cbeTitle:null,
                        cbeDescription: null,
                        cbeSectionName: null,
                        cbeTimeLimit: null,
                        cbeNumberOfPauses: null,
                        cbeLengthOfPauses: null,
                    }
                },
                watch: {
                    cbeName: function (val) {
                        this.$store.commit('setCBEName', this.cbeName)
                        console.log(this.$store.state.cbeName)
                    },
                    cbeTitle: function (val) {
                        this.$store.commit('setCbeTitle', this.cbeTitle)
                        console.log(this.$store.state.cbeTitle)
                    },
                    cbeDescription: function (val) {
                        this.$store.commit('setCbeDescription', this.cbeDescription)
                        console.log(this.$store.state.cbeDescription)
                    },
                    setCbeSectionName: function (val) {
                        this.$store.commit('setCbeSectionName', this.cbeSectionName)
                        console.log(this.$store.state.setCbeSectionName)
                    },
                    cbeTimeLimit: function (val) {
                        this.$store.commit('setCbeTimeLimit', this.cbeTimeLimit)
                        console.log(this.$store.state.cbeTimeLimit)
                    },
                    cbeNumberOfPauses: function (val) {
                        this.$store.commit('setCbeNumberOfPauses', this.cbeNumberOfPauses)
                        console.log(this.$store.state.cbeNumberOfPauses)
                    },                    
                    cbeLengthOfPauses: function (val) {
                        this.$store.commit('setCbeLengthOfPauses', this.cbeLengthOfPauses)
                        console.log(this.$store.state.cbeLengthOfPauses)
                    },                    
                },
    }
</script>

<style lang="scss" scoped>
input, output, textarea, select, button {
  clear: both;
  float: right;
  width: 70%;
}

label {
  float: left;
  width: 30%;
  text-align: right;
  padding: 0.25em 1em 0 0;
} 
</style>
