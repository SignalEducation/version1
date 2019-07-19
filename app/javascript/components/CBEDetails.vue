<template>
    <div class="form-row align-items-left col-lg-10 ml-1">   

  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Name</label>
    <div class="ml-4">
      <input v-model="cbeName" type="email" class="form-control ml-5" id="colFormLabel" placeholder="Name">
    </div>
  </div>

  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Title</label>
    <div class="ml-4">
      <input type="email" class="form-control ml-5" id="colFormLabel" placeholder="Title">
    </div>
  </div>
      
  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Description</label>
    <div class="ml-4">
      <input type="email" class="form-control ml-5" id="colFormLabel" placeholder="Description">
    </div>
  </div>
      
  <div class="form-group row">
    <label for="colFormLabel" class="col-md-2 col-form-label">Time</label>
    <div class="ml-4">
      <input type="email" class="form-control ml-5" id="colFormLabel" placeholder="Time Limit">
    </div>
  </div>

  <div class="form-group row">
    <label for="colFormLabel" class="col-sm-2 col-form-label">Pauses</label>
    <div class="ml-4">
      <input type="email" class="form-control ml-5" id="colFormLabel" placeholder="Pauses">
    </div>
  </div>

    <div class="form-group row">
    <label for="colFormLabel" class="col-sm-2 col-form-label">Length</label>
    <div class="ml-4">
      <input type="email" class="form-control ml-5" id="colFormLabel" placeholder="Lenght of pauses">
    </div>
  </div>
      
       
    </div>
</template>

<script>
    export default {
                data: function () {
                    return {
                        cbeName: null
                    }
                },
                watch: {
                    cbeName: function (val) {
                        this.$store.commit('setCBEName', this.cbeName)
                        console.log(this.$store.state.cbeName)
                        //this.$store.state.currentSubjectId = 1111
                        //this.$store.commit('setCBEId', this.cbeName)
                    }
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
