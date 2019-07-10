<template>
  <div id="app">

    <div>
       <button v-on:click="showSubjects">Show Subjects</button>

    <select v-model="selected">
                <option>Choose Option</option>
                <option v-for="option in options" v-bind:value="option.id">
                    {{option.name}}
                </option>
        </select>
    </div>

  </div>
</template>

<script>
import axios from 'axios'
export default {
el: 'app',
  data: function () {
    return {
       selected: "Choose Option",
            options: [
                { id: 1, name: 'A' },
                { id: 2, name: 'B' },
                { id: 3, name: 'C' }
            ]
		}


  },
   methods: {
             showSubjects: function(page, index) {
                                                   console.log('TEST 1')
                                                   axios.get('http://localhost:3000/cbes/1/get_subjects/')
                                                     .then(response => {
                                                     this.options = response.data
                                                     console.log(this.subjects)
                                                     })
                                                    .catch(e => {
                                                     console.log('Error')
                                                     })
                                     },
   },

}
</script>


<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
