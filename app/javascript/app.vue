<template>
  <div id="app">
    <p><button v-on:click="showSubjects">Show Subjects</button>
    <select v-model="selectedSubject">
          <li v-for="subject in testSubjects" :value="subject.id">
            {{ subject.name }}
          </li>
        </select>

      <div id="selector">
          <span>Seleczvzcxvted XXX: </span>
          <select v-model="selectedSubject">
            <option v-for="(id, name) in selectedSubjects" :value="id">{{ name }}</option>
          </select>
          <span>Selected: {{ selectedSubject }}</span>
        </div>

    </p>
    <p>
      <select v-model="selected">
      <option v-for="option in options" v-bind:value="value" v-bind:key="option.value">
        {{ value }}
      </option>
</select>
<span>Selected: {{ selected }}</span>
      </p>
    <button v-on:click="createCBE">Create CBE</button> <input v-model="cbeName" placeholder="CBE Name">
    <br/><br/>
    <button v-on:click="">Create Section</button> <input v-model="sectionName" placeholder="Section Name">
    <br/><br/>

    <br/><br/>
    <button v-on:click="getCBEs">Get CBEs</button>
    <br/><br/>

  </div>
</template>

<script>
import axios from 'axios'
export default {
el: 'app',
  data: function () {
    return {
      message: "Create A CBE",
      cbeName,
      sectionName,
      selectedSubject: null,
      testSubjects: [{id: 1, name: 'Number 1'},{id: 2, name: 'Number 2'}],
      subjects: [],
      selected,
      options: [
                { text: 'One', value: 'A' },
                { text: 'Two', value: 'B' },
                { text: 'Three', value: 'C' }
               ]
              }
    
  },
   methods: {
          showSubjects: function(page, index) {
                                                console.log('TEST 1')
                                                axios.get('http://localhost:3000/cbes/1/get_subjects/')
                                                  .then(response => {
                                                  this.subjects = response.data
                                                  console.log(this.subjects)
                                                  })
                                                 .catch(e => {
                                                  console.log('Error')
                                                  })
                                  },
          getCBEs: function(page, index) {
                        console.log('TEST 1')
                        axios.get('http://localhost:3000/cbes/1/get_subjects')
                          .then(response => {
                          this.cbe_data = response.data
                           console.log(this.cbe_data)
                          })
                         .catch(e => {
                          console.log(e)
                          })
          },
          createCBE: function(page, index) {
                          console.log('cbeName: ' + this.cbeName)
                          axios.post('http://localhost:3000/cbes/1/create_it', {cbeName: this.cbeName})
                          .then(response => { console.log(response.status)})
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
