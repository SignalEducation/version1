<template>
  <div id="app">
    <p>{{ message }}</p>
    <button v-on:click="createCBE">Create CBE</button>
    <br/><br/>
    <button v-on:click="createSection">Create Section</button>
    <br/><br/>
    <button v-on:click="createQuestion">Create Question</button>
    <br/><br/>
    <button v-on:click="getCBEs">Get CBEs</button>
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
          },
          getCBEs: function(page, index) {
                        axios.get('localhost:3000/cbes/fetch')
                          .then(response => {
                           .this.contacts = response.data
                          })
                         .catch(e => {
                          this.error.push(e)
                          })
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
