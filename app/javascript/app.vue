<template>
    <main>
      <article class="">
        <div class="container-fluid">
          <header class="hero-section">
          <section class="pb-md-6 pb-5">  
            <div class="row">
              <div class="col-sm-12">
                <div class="panel-body no-top-padding">
                  <split-pane  :min-percent='50' :default-percent='50' split="vertical">
                    <template slot="paneL">

                    
                     <div>
            
                      
                      <Subjects ref="subjects"></Subjects>
                      
                      <span>{{ errors.first('email') }}</span>

                     </div>



                    <div class="form-group row">
                      
                      <div class="col-md-10">
                        <p>{{currentCBEId}}</p>
                        <button v-on:click="createNewCBE">Create a new CBE</button>  
                      </div>
                     </div>
                     

                      <div v-if="selectedSubjectId !== null">
                        <CBESection> </CBESection>
                      </div>
                     <div v-if="selectedSubjectId !== null">          
                      <button v-on:click="saveNewCBE">Save</button>
                    </div>

                    </template>
                    <template slot="paneR">
                        <div v-if="selectedSubjectId !== null">
                          <CBEDetails> </CBEDetails>
                        </div>
                        <div v-if="selectedSubjectId !== null">
                          <span class="badge badge-pill badge-primary">CBE ID {{createdCBE.cbeId}}</span>
                          <span class="badge badge-pill badge-primary">CBE Name {{createdCBE.cbeName}}</span>
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
    import Admin from './components/admin'
    import Exam from './components/exam'
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
                cbeDetails: [],
                testName: [],
                options: []
            }


        },
        computed: {
            currentCBEId (){
              return this.$store.state.currentCBEId
            }
        },
        methods: {
            storeCBEName: function (page, index) {
                console.log('cbeName: ' + this.cbeName + 'selectedSubjectId -- ' + this.selectedSubjectId)

                axios.post('http://localhost:3000/api/cbes', {
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
                
              
                axios.post('http://localhost:3000/api/cbes', {cbe_id: this.createdCBE.cbeId})
                    .then(response => {
                        console.log(response.status)
                    })
                    .catch(error => {
                        console.log(error)
                    })
            },

            saveNewCBE: function (page, index) {

                this.cbeDetails = {}

                this.selectedSubjectId = this.$refs.subjects.selectedSubject
               
                this.selectedSubjectId = this.$refs.subjects.selectedSubject
                this.cbeDetails['name'] = this.$store.state.cbeName 
                this.cbeDetails['description'] =this.$store.state.cbeDescription 
                this.cbeDetails['time'] = this.$store.state.cbeTimeLimit 
                this.cbeDetails['number_of_pauses'] =this.$store.state.cbeNumberOfPauses 
                this.cbeDetails['length_of_pauses'] = this.$store.state.cbeLengthOfPauses 
                this.cbeDetails['subject_course_id'] = this.selectedSubjectId 
                this.cbeDetails['title'] = this.$store.state.cbeTitle

                
                this.$store.state.currentSubjectId = this.selectedSubjectId
                console.log(JSON.stringify(this.cbeDetails))
                console.log('cbeName: ' + JSON.stringify(this.testName))
                console.log({cbe: this.cbeDetails})
                
                axios.post('http://localhost:3000/api/cbes', {cbe: this.cbeDetails})
                    .then(response => {
                        console.log(response.status)
                        this.createdCBE = response.data
                        console.log("******** " + JSON.stringify(response.data.cbeId))
                        this.$store.commit('setCurrentCbeId', this.createdCBE.cbeId)
                        console.log(" From store ******** " + this.createdCBE.cbeId )
 
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
