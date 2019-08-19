<template>
  <div class="form-row form-horizontal">

    <div class="col-sm-6">
      <div class="form-group">
        <label for="colFormLabel">Name</label>
        <div class="input-group input-group-lg">
          <input v-model="cbeName"  class="form-control" id="colFormLabel" placeholder="Name">
        </div>
      </div>

      <div class="form-group">
        <label for="colFormLabel">Title</label>
        <div class="input-group input-group-lg">
          <input  v-model="cbeTitle" class="form-control" id="colFormLabel" placeholder="Title">
        </div>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="colFormLabel">Description</label>
        <div class="input-group input-group-lg">
          <input v-model="cbeDescription" class="form-control" id="colFormLabel" placeholder="Description">
        </div>
      </div>

      <div class="form-group">
        <label for="colFormLabel">Time</label>
        <div class="input-group input-group-lg">
          <input v-model="cbeTimeLimit" class="form-control" id="colFormLabel" placeholder="Time Limit">
        </div>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="colFormLabel">Pauses</label>
        <div class="input-group input-group-lg">
          <input v-model="cbeNumberOfPauses" class="form-control" id="colFormLabel" placeholder="Pauses">
        </div>
      </div>

      <div class="form-group">
        <label for="colFormLabel">Length</label>
        <div class="input-group input-group-lg">
          <input v-model="cbeLengthOfPauses" class="form-control" id="colFormLabel" placeholder="Length of pauses">
        </div>
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
                props: ['showCBEDetails', 'selectedSubject'],

                watch: {
                    cbeName: function (val) {
                        this.$store.commit('setCbeName', this.cbeName)
                    },
                    cbeTitle: function (val) {
                        this.$store.commit('setCbeTitle', this.cbeTitle)
                    },
                    cbeDescription: function (val) {
                        this.$store.commit('setCbeDescription', this.cbeDescription)
                    },
                    setCbeSectionName: function (val) {
                        this.$store.commit('setCbeSectionName', this.cbeSectionName)
                    },
                    cbeTimeLimit: function (val) {
                        this.$store.commit('setCbeTimeLimit', this.cbeTimeLimit)
                    },
                    cbeNumberOfPauses: function (val) {
                        this.$store.commit('setCbeNumberOfPauses', this.cbeNumberOfPauses)
                    },                    
                    cbeLengthOfPauses: function (val) {
                        this.$store.commit('setCbeLengthOfPauses', this.cbeLengthOfPauses)
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
