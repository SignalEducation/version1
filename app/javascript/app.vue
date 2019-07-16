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

                    
                     <div>
                       <component v-bind:is="currentView" v-on:change-view="updateView"></component>
                      <Subjects ref="subjects"></Subjects>
                     </div>

                     <br/><br/><br/>
                      <button v-on:click="createNewCBE">Create CBE</button>
                    <br/><br/><br/>
                       <button @click="cbeQuestionValid = true">Show CBE Questions</button>

                      <br/><br/><br/>

                      <div v-if="selectedSubjectId !== null">
                        <button v-on:click="storeCBEName">Save CBE Name</button>
                        <input v-model="cbeName" placeholder="CBE Name">
                      </div>

                      
  

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
                selectedSubjectId: null,
                message: 'Test',
                cbeQuestionValid: false,
                options: []
            }


        },
        methods: {
            storeCBEName: function (page, index) {
                console.log('cbeName: ' + this.cbeName + 'selectedSubjectId -- ' + this.selectedSubjectId)
                axios.post('http://localhost:3000/cbes/1/create_it', {
                    cbe_name: this.cbeName,
                    selected_subject: this.selectedSubjectId,
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
            createNewCBE: function (page, index) {
                this.selectedSubjectId = this.$refs.subjects.selectedSubject
                this.$store.state.currentSubjectId = this.selectedSubjectId
                console.log('cbeName: ' + this.cbeName)
                console.log('TEST VUEX' + this.$store.state.currentSubjectId )
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
