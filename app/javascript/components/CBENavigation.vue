<template>


  <section>
    <h1>CBE Details</h1>
    <p> {{ this.cbes.name }}</p>
    <p> {{ this.$store.state.currentCbeId}}</p>


    <!-- Debug CBE - Allows you to manually set the current cbe -->
    <div>
        <input v-model="currentCbeId" placeholder="Set current CBE">
        <button v-on:click="setCurrentCBE">Set as Current CBE ID</button>
    </div>
    <!-- Debug CBE - Allows you to manually set the current cbe -->
    
    <b-button  @click="showCbeSection">Add a Section</b-button>
    <div role="tablist">
     Current CBE: {{ this.$store.state.currentCbeId}}
     Current CBESection : {{ this.$store.state.currentSectionId}}
    <div v-for="cbe_section in cbes.cbe_sections">

      <b-card no-body class="mb-1">
        
        <b-card-header header-tag="header" class="p-1" role="tab">
          <b-button block href="#" v-b-toggle.accordion-1 variant="info">{{cbe_section.name }}</b-button>
        </b-card-header>
        <b-collapse id="accordion-1" visible accordion="my-accordion" role="tabpanel">
          <b-card-body>
            <b-card-text>Section Questions</b-card-text>
            <div v-for="question in cbeQuestions">
              <b-card v-if="cbe_section.id == question.cbe_section_id"> 
                {{question.text}}  <b-link href="#foo">Edit</b-link>
              </b-card>
            </div>

        <!-- Add a question -->
           
              
          
        <!-- Add a question -->

            <b-button>Add a question</b-button>
          </b-card-body>
        </b-collapse>
      </b-card>
     
    </div>
    <b-button>Add a question</b-button>
    <QuestionsList></QuestionsList>

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
         sampleSection: {"id": 5,"name": "Section A"},
          cbes: {
              "cbe_id": 1,
              "name": "ACCA CBE",
              "details": "Beginners Guide to Accountancy",
              "cbe_sections": [{
                  "id": 5,
                  "name": "Section A"
                }, {
                  "id": 6,
                  "name": "Section B"
                },
                {
                  "id": 7,
                  "name": "Section C"
                }
              ]
            },
         cbeAnswers: [
            {"id": 1, "cbe_question_id": 5,"text": "40,000","type": "Multiple Choice","correctAnswer": true},
            {"id": 2, "cbe_question_id": 5,"text": "15,000","type": "Multiple Choice","correctAnswer": false},
            {"id": 3, "cbe_question_id": 5,"text": "1,000","type": "Multiple Choice","correctAnswer": false},
            {"id": 4, "cbe_question_id": 5,"text": "4,000","type": "Multiple Choice","correctAnswer": false}
          ],
	        cbeQuestions: [
            {"id": 5, "cbe_section_id": 5,"text": "How much does an Accountant Earn?","type": "Multiple Choice","correctAnswer": true},
            {"id": 6, "cbe_section_id": 5,"text": "How long does it take to become an accountant?","type": "Multiple Choice","correctAnswer": false},
            {"id": 7, "cbe_section_id": 5,"text": "What is a P&L?","type": "Multiple Choice","correctAnswer": false},
            {"id": 8, "cbe_section_id": 5,"text": "When was the ACCA founded?","type": "Multiple Choice","correctAnswer": false}
          ]
        }
      },
      mounted() {
        this.fetchQuestionTypes()
      },
      methods: { 
        setCurrentCBE: function (page, index) {
          this.$store.commit('setCurrentCbeId', this.currentCbeId)
        },
        showCbeSection: function(page, index) {
           this.$store.state.showSections = true
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

      }
    }

</script>
