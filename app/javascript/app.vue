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
  
                     <div v-if="showSubjects = true">
                        <Subjects ref="subjects"></Subjects> 
                      </div>
                   
                    <div class="form-group row">
                        <div class="col-md-10">
                          <button v-on:click="createNewCBE">Create a new CBE</button>  
                           {{this.$store.state.showQuestions}}
                        </div>
                    </div>

                    <div v-if="cbeSectionButton === true">
                      <button v-on:click="makeCBESectionVisible">Add Section</button>
                    </div>


                      <div v-show="this.$store.state.showQuestions">
                        <button v-on:click="makeQuestionDetailsVisible">Add Question</button>
                      </div>

                        <div v-show="showQuestionDetails">
                          <QuestionsList> </QuestionsList>
                        </div>

                    </template>
                    <template slot="paneR">
                      <div v-show="showCBEDetails">
                        <CBEDetails> </CBEDetails>
                        <button v-on:click="saveNewCBE">Save</button>
                      </div>

                        <div v-show="this.$store.state.showSections ">
                        <CBESection> </CBESection>
                        <button v-on:click="saveSection">Save</button>
                      </div>

                    <div v-show="showQuestionDetails">

                          <CBEMultipleChoiceQuestion> </CBEMultipleChoiceQuestion>
                    
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
    import Admin from './components/Admin'
    import Exam from './components/Exam'
    import Subjects from './components/Subjects'
    import CBESettings from './components/CBESettings'
    import CBEDetails from './components/CBEDetails'
    import CBESection from './components/CBESection'
    import CBEMultipleChoiceQuestion from './components/CBEMultipleChoiceQuestion'
    import QuestionsList from './components/QuestionsList'
    import splitPane from 'vue-splitpane'


    export default {
        components: {
           Admin,
           CBESettings,
           CBEDetails,
           CBESection,
           Exam,
           Subjects,
           CBEMultipleChoiceQuestion,
           QuestionsList,
        },

        data: function () {
            return {
                createdCBE: [],
                selectedSubjectId: null,
                message: 'Test',
                cbeQuestionValid: false,
                cbeDetails: [],
                testName: [],
                options: [],
                showCBESection: false,
                showCBEDetails: false,
                showSubjects: true,
                cbeSectionButton: false,
                sectionDetails: {},
                sectionName: null,
                sectionLabel: null,
                sectionDescription: null,
                createdSection: null,
                showQuestionDetails: false
            }


        },
        computed: {
            currentCBEId (){
              return this.$store.state.currentCBEId
            }
        },
        methods: {
            makeCBESectionVisible: function(page, index) {
              this.$store.state.showSections = true
              this.showCBEDetails = false

            },
            makeQuestionDetailsVisible: function(page, index) {
              this.showQuestionDetails = true
            },
            createNewCBE: function (page, index) {
                this.selectedSubjectId = this.$refs.subjects.selectedSubject
                this.$store.state.currentSubjectId = this.selectedSubjectId
                this.showCBEDetails = true
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
                this.showSubjects = false
                
                axios.post('http://localhost:3000/api/cbes/', {cbe: this.cbeDetails})
                    .then(response => {
                        console.log(response.status)
                        this.createdCBE = response.data
                        this.$store.commit('setCurrentCbeId', this.createdCBE.cbeId)
                        if(this.createdCBE.cbeId > 0){
                          this.cbeSectionButton = true
                        }
                    })
                    .catch(error => {
                        console.log(error)
                    })
            },

             saveSection: function (page, index) {
                this.sectionDetails['sectionName'] = this.sectionName
                this.sectionDetails['sectionLabel'] = this.sectionLabel
                this.sectionDetails['sectionDescription'] = this.sectionDescription
                this.sectionDetails['cbe_id'] = this.$store.state.currentCbeId

                axios.post('http://localhost:3000/api/cbes/' + this.$store.state.currentCbeId + 'create_section', {cbe_section: this.sectionDetails})
                    .then(response => {
                        this.createdSection = response.data
       
                        this.$store.commit('setCurrentSectionId', this.createdSection.cbeSectionId)
                        if (this.$store.state.currentSectionId > 0 ) {
                            this.showQuestions = true
                            this.showCBESection = false
                        }
                    })
                    .catch(error => {
                        console.log(error)
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
