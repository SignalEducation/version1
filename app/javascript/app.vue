<template>
  <div id="app">
    <p>{{ message }}</p>
    <button v-on:click="createCBE">Create CBE</button> <input v-model="cbeName" placeholder="CBE Name">
    <br/><br/>
    <button v-on:click="">Create Section</button> <input v-model="sectionName" placeholder="Section Name">
    <br/><br/>
    <button v-on:click="">Create Question</button> <input v-model="questionTitle" placeholder="Question Title">
    <br/><br/>
    <button v-on:click="getCBEs">Get CBEs</button>
    <br/><br/>
    <button v-on:click="getCBEs">Create CBE</button>
  </div>
</template>

<script>
import axios from 'axios'
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
                        console.log('TEST 1')
                        axios.get('http://localhost:3000/cbes/show')
                          .then(response => {
                          this.cbe_data = response.data
                           console.log(this.cbe_data)
                          })
                         .catch(e => {
                          console.log(e)
                          })
          },
          createCBE: function(page, index) {
                          console.log('TEST 1')
                          axios.post('http://localhost:3000/cbes/new',
                            cbeName: 'Test'
                          )
                            .then(response => { console.log(response)})
                          .catch(error => {console.log(error)})
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
