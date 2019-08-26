<template>
  <div class="row">
    <div class="col-sm-10">
      <div class="form-group">
        <label for="colFormLabelSm">Subject</label>
        <div class="input-group input-group-lg">
          <select v-model="selectedSubject" class="form-control custom-select">
            <option class="col-md-8" v-for="option in options" v-bind:value="option.id">
              {{option.name}}
            </option>
          </select>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

  export default {
    mounted() {
      this.showSubjects();
     // this.fetchQuestionTypes();
     //  this.fetchQuestionStatuses();
      // TODO this.fetchSectionTypes()
    },
    data: function() {
      return {
        selectedSubject: null,
         questionTypes: [ 
          'Multiple Choice', 
          'Multiple Response', 
          'Complete', 
          'Fill In The Blank', 
          'Drag & Drop','Dropdown List',
          'Hot Spot',
          'Spreadsheet',
          'Open Text' ]
        ,
        options: [
          {id: 1, name: 'Course 1', exam_body_id: 1,  description: 'Course 1 description'},
          {id: 2, name: 'Course 2', exam_body_id: 2,  description: 'Course 2 description'},
          {id: 3, name: 'Course 3', exam_body_id: 2,  description: 'Course 3 description'},
          {id: 4, name: 'Course 4', exam_body_id: 1,  description: 'Course 4 description'},
        ],
      };
    },
    methods: {
      showSubjects: function(page, index) {
      this.$store.questionTypes = this.questionTypes
      /* TODO comment back in when subjects from the backend  
      axios
          .get("http://localhost:3000/api/subjects/")
          .then(response => {
            this.options = response.data;
          })
          .catch(e => {
            console.log("Error");
          });
          */
      },
      fetchQuestionTypes: function(page, index) {
        axios
          .get("http://localhost:3000/api/v1/cbe/question_types/")
          .then(response => {
            this.$store.questionTypes = response.data;
            return response.data;
          })
          .catch(e => {
            console.log("Error" + e);
          });
      },
      fetchQuestionStatuses: function(page, index) {
        axios
          .get("http://localhost:3000/api/v1/cbe/question_statuses/")
          .then(response => {
            this.$store.questionStatuses = response.datax;
          })
          .catch(e => {
            console.log("Error" + e);
          });
      },
      fetchSectionTypes: function(page, index) {
        axios
          .get("http://localhost:3000/api/v1/cbe/section_types/")
          .then(response => {
            this.$store.SectionTypes = response.data;
          })
          .catch(e => {
            console.log("Error" + e);
          });
      }
    }
  };
</script>


<style scoped>
  p {
    font-size: 2em;
    text-align: center;
  }
</style>
