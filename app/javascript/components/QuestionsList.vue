<template>
  <div>
    <div class="form-group row">
      <div v-if="isLoaded">
        <label for="colFormLabelSm">Question List</label>
        <div class="input-group input-group-lg">
          <select :value="this.$store.selectedQuestionType" class="form-control custom-select" @change="onChange($event)">
            <option class="col-md-8" v-for="option in this.$store.questionTypes" v-bind:value="option.name" >
              {{option.name}}
            </option>
          </select>

          {{this.$store.selectedQuestionType}}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

  export default {
    data: function() {
      return {
        isLoaded: false,
        questionTypes: [ 'Multiple Choice', 
          'Multiple Response', 
          'Complete', 
          'Fill In The Blank', 
          'Drag & Drop','Dropdown List',
          'Hot Spot',
          'Spreadsheet',
          'Open Text' ],
      };
    },
   /*  
   
   TODO - commented out until we use the API to get question types, hardcoded for now. 
   
   mounted() {
      this.fetchQuestionTypes();
    },
    */
    computed: {
      selectedSearchType: {
        get() {
          return this.$store.selectedQuestionType; //value from store
        },
        selectedSearchType(val) {
          this.$store.commit("selectedSearchType", val);
        }
      }
    },
    /*
      methods: {

        TODO - commented out until we use the API to get question types, hardcoded for now. 
        fetchQuestionTypes: function(page, index) {

        
        axios
            .get("http://localhost:3000/api/v1/cbe/question_types/")
            .then(response => {
              this.$store.questionTypes = response.data;
              this.isLoaded = true;
            })
            .catch(e => {
              console.log("Error" + e);
            });
            
        },
      */
      onChange(event) {
        this.$store.commit("setCurrentQuestionType", event.target.value);
        console.log(event.target.value);
        console.log(this.$store.state.currentQuestionType);
        if (this.$store.state.currentQuestionType == "Multiple Choice") {
          this.$store.commit("setMultipleChoiceSelected", true);
        }
        console.log(this.$store.state.multipleChoiceSelected);
      }
    }
</script>
