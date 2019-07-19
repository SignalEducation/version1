<template>
    <main>
      <article class="">
        <div class="container-fluid">
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
                      
                      <span>{{ errors.first('email') }}</span>

                     </div>



                    <div class="form-group row">
                      
                      <div class="col-md-10">
                        <button v-on:click="createNewCBE">Create a new CBE</button>  
                      </div>
                     </div>
                     

                      <div v-if="selectedSubjectId !== null">
                        <CBESection> </CBESection>
                      </div>
                     <div v-if="selectedSubjectId !== null">          
                      <button v-on:click="storeCBEName">Save</button>
                    </div>

                    </template>
                    <template slot="paneR">

                      
                        
                        <div v-if="selectedSubjectId !== null">
                          <CBEDetails> </CBEDetails>
                        </div>

                        <p class="text-info">CBE ID : {{createdCBE.cbeId}} --- New CBE Name: {{createdCBE.cbeName}} ---  {{selectedSubject}}</p>
                    
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
    import CBEDetails from './components/CBEDetails'
    import CBESection from './components/CBESection'
    import splitPane from 'vue-splitpane'


    export default {
        components: {
           Admin,
           CBESettings,
           CBEDetails,
           CBESection,
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
                console.log('cbeName: ' + this.$store.state.cbeName)
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
