<template>
    <main>
      <article class="">
        <div class="container">
          <header class="hero-section">
          <section class="pb-md-6 pb-5">  
            <div class="row">
              <div class="col-sm-12">
                <div class="panel-body no-top-padding">
                  <split-pane v-on:resize="resize" :min-percent='50' :default-percent='50' split="vertical">
                    <template slot="paneL">

                    
                     
                     <Subjects></Subjects>

                       <button @click="cbeQuestionValid = true">Show CBE Questions</button>
                          
                      {{selected}}
                      <br/><br/><br/>
                      <div v-if="selectedSubject !== null">
                        <button v-on:click="createCBE">Create CBE</button>
                        <input v-model="cbeName" placeholder="CBE Name">
                      </div>

                      <br/><br/><br/>
                      <button v-on:click="createSection">Create Section</button>
                      <p>Testing admin</p>
                      <Admin></Admin>
                      <input v-model="sectionName" placeholder="Section Name">
                    </template>
                    <template slot="paneR">
                      <span><p>CBE DB Index >> {{createdCBE.cbeId}} --- New CBE Name: {{createdCBE.cbeName}} ---  {{selectedSubject}}</p></span>
                        <div v-if="cbeQuestionValid">
                          <p>fafdsa</p>
                          <Admin>fdsfads</Admin>
                          <input v-model="cbeName" placeholder="CBE Title">
                          <input v-model="cbeName" placeholder="Exam length">
                        </div>
                    
                    </template>
                  </split-pane>
                </div>
              </div>
          </div>
          </section>
          </header> 
        </div>
      </article>
    </main>
</template>


<script>
    import axios from 'axios'
    import Admin from './components/Admin'
    import Exam from './components/Exam'
    import Subjects from './components/Subjects'
    import CBESettings from './components/CBESettings'
    import splitPane from 'vue-splitpane'


    export default {
        components: {
           Admin,
           CBESettings,
           Exam,
           Subjects,
        },

        data: function () {
            return {
                createdCBE: [],
                selectedSubject: null,
                message: 'Test',
                cbeQuestionValid: false,
                options: []
            }


        },
        methods: {
            
            createCBE: function (page, index) {
                console.log('cbeName: ' + this.cbeName)
                axios.post('http://localhost:3000/cbes/1/create_it', {
                    cbe_name: this.cbeName,
                    selected_subject: this.selectedSubject
                })
                    .then(response => {
                        console.log(response.status)
                        console.log(response.data)
                        this.createdCBE = response.data
                        console.log(this.createdCBE.cbeId)
                    })
                    .catch(error => {
                        console.log(error)
                    })
            },
            createSection: function (page, index) {
                console.log('cbeName: ' + this.cbeName)
                axios.post('http://localhost:3000/cbes/1/create_it', {cbe_id: this.createdCBE.cbeId})
                    .then(response => {
                        console.log(response.status)
                    })
                    .catch(error => {
                        console.log(error)
                    })
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
