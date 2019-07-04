<template>
  <div id="app">
    <p>{{ message }}</p>
    <button v-on:click="createCBE">Create CBE</button>
    <br/><br/>
    <button v-on:click="creatSection">Create Section</button>
    <br/><br/>
    <button v-on:click="creatQuestion">Create Question</button>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Create A CBE",
      cbe_data: []
    }
  },
   methods: {
          createCBE: function(page, index) {
              console.log("this is working. Page:", page, '. Index:', index)
          }
      }
}
</script>





<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
