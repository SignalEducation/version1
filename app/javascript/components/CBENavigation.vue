<template>
  <section>
    <h1>CBE Details</h1>

    <p> {{ this.cbes.name }}</p>
    <p> {{ currentCbeId}}</p>
    <b-button @click="showQuestion">Add a question 1</b-button>

    <div role="tablist" class="pt-5">
      <div v-for="(cbe_section, index) in cbeSections">
        <b-card no-body class="mb-1">
          <b-card-header header-tag="header" class="p-1" role="tab">
            <b-button block href="#" v-b-toggle="'accordion-' + index" variant="info">{{ cbe_section.name }}</b-button>
          </b-card-header>

          <b-collapse v-bind:id="'accordion-'+ index" accordion="my-accordion" role="tabpanel">
            <b-card-body>
              <b-card-text>{{ cbe_section.name }}</b-card-text>

              <div v-for="cbe_question in cbeQuestions">
                <b-link href="#foo">Edit - {{cbe_question.text}}</b-link>
              </div>

            </b-card-body>
          </b-collapse>
        </b-card>

        <!--
        <b-card v-if="cbe_section.id == question.cbe_section_id">
          {{question.text}}  <b-link href="#foo">Edit</b-link>
        </b-card>
        -->
      </div>

      <b-button  @click="showCbeSection">Add a Section</b-button>
    </div>
  </section>
</template>

<script>
  import axios from 'axios'
  import QuestionsList from './QuestionsList'

  export default {
    components: {
      QuestionsList,
    },

     data: function(){
       return {
         currentCbeId: 109,
         newSections: [],
         questionTypes: [],
         cbes: {
              "cbe_id": 1,
              "name": "ACCA CBE",
              "details": "Beginners Guide to Accountancy"
         },
         cbeSections: [
            {"id": 1, "cbe_id": 1,"name": "40,000"},
            {"id": 2, "cbe_id": 1,"name": "15,000"},
            {"id": 3, "cbe_id": 1,"name": "1,000"},
            {"id": 4, "cbe_id": 1,"name": "4,000"}
          ],
          cbeQuestions: [
            {"id": 5, "cbe_section_id": 1,"text": "How much does an Accountant Earn?","type": "Multiple Choice","correctAnswer": true},
            {"id": 6, "cbe_section_id": 1,"text": "How long does it take to become an accountant?","type": "Multiple Choice","correctAnswer": false},
            {"id": 7, "cbe_section_id": 1,"text": "What is a P&L?","type": "Multiple Choice","correctAnswer": false},
            {"id": 8, "cbe_section_id": 1,"text": "When was the ACCA founded?","type": "Multiple Choice","correctAnswer": false}
          ],
         cbeAnswers: [
           {"id": 1, "cbe_question_id": 5,"text": "40,000","type": "Multiple Choice","correctAnswer": true},
           {"id": 2, "cbe_question_id": 5,"text": "15,000","type": "Multiple Choice","correctAnswer": false},
           {"id": 3, "cbe_question_id": 5,"text": "1,000","type": "Multiple Choice","correctAnswer": false},
           {"id": 4, "cbe_question_id": 5,"text": "4,000","type": "Multiple Choice","correctAnswer": false}
         ]
        }
      },
      mounted() {
        this.fetchQuestionTypes()
        //this.setCbeQuestions()
      },
      methods: {
        setCbeQuestions: function (page, index) {
          //this.$store.commit(this.cbeQuestions)

        },
        setCurrentCBE: function (page, index) {
          this.$store.commit('setCurrentCbeId', this.currentCbeId)
        },
        showCbeSection: function(page, index) {
          this.$store.state.showCBEDetails = false
          this.$store.state.showSections = true
          this.$store.state.showCBEMultipleChoiceQuestion = false
        },
        fetchQuestionTypes: function (page, index) {
          axios.get('http://localhost:3000/api/cbe_question_types/')
            .then(response => {
              console.log("Loaded question types")
                this.$store.questionTypes = response.data
                this.questionTypes = this.$store.questionTypes
                //console.log(response.data[0].data)
            })
            .catch(e => {
                console.log('Error' + e)
            })
        },
        showQuestion: function(page, index) {
          console.log("Show Question")
          console.log(this.$store.state.showCBEMultipleChoiceQuestion)
          this.$store.state.showSections = false
          this.$store.state.showCBEDetails = false
          this.$store.state.showCBEMultipleChoiceQuestion = true
          console.log(this.$store.state.showCBEMultipleChoiceQuestion)
        },
      },
    }
</script>
