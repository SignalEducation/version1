<template>
  <div id="app">

    <div>
       <button v-on:click="showSubjects">Show Subjects</button>

    <select v-model="selectedSubject">
                <option>Choose Option</option>
                <option v-for="option in options" v-bind:value="option.id">
                    {{option.name}}
                </option>
        </select>
        {{selected}}
        <br/><br/><br/>
        <button v-on:click="createCBE">Create CBE</button> <input v-model="cbeName" placeholder="CBE Name">
        <br/><br/><br/>
        <button v-on:click="createSection">Create Section</button> <input v-model="sectionName" placeholder="Section Name">

        <span>New CBE ID: {{ createCBEId }}
        <paragraph v-bind:data="createCBEId">{{ createCBEId }}</paragraph></span>
    </div>

    <div>



    </div>

  </div>
</template>

<script>
import axios from 'axios'
export default {
el: 'app',
  data: function () {
    return {
       createdCBEId: null,
       selectedSubject: "Subject",
            options: []
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
                                               createCBE: function(page, index) {
                                                               console.log('cbeName: ' + this.cbeName)
                                                               axios.post('http://localhost:3000/cbes/1/create_it', {cbe_name: this.cbeName, selected_subject: this.selectedSubject})
                                                               .then(response => {
                                                               console.log(response.status)
                                                               console.log(response.data)
                                                               this.createdCBEId = response.data.cbeId
                                                               })
                                                               .catch(error => {console.log(error)})
                                                         },
                                               createSection: function(page, index) {
                                                               console.log('cbeName: ' + this.cbeName)
                                                               axios.post('http://localhost:3000/cbes/1/create_it', {cbeName: this.cbeName})
                                                               .then(response => { console.log(response.status)})
                                                               .catch(error => {console.log(error)})
                                                         }

   },

}
</script>


<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
