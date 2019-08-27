<template>

  <div>
    <div class="row">
      <div class="col-sm-10">
        <div class="form-group">
          <label for="colFormLabelSm">Subject Course</label>
          <div class="input-group input-group-lg">
            <select v-model="selectedSubjectCourse" class="form-control custom-select">
              <option class="col-md-8" v-for="option in options" v-bind:value="option.id">
                {{option.name}}
              </option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Create CBE button -->

    <div class="form-group row">
      <div class="col-md-10">
        <button v-on:click="createNewCBE" class="btn btn-secondary">Create a new CBE</button>
      </div>
    </div>

    <!-- Save CBE --> 
    <button v-on:click="saveNewCBE" class="btn btn-primary">Save CBE</button>
    
  </div>
</template>
  
  <!-- Create CBE button -->


<script>
  import axios from "axios";

  export default {
    mounted() {
      this.showSubjects();
      this.fetchQuestionTypes();
     //  this.fetchQuestionStatuses();
      // TODO this.fetchSectionTypes()
    },
    data: function() {
      return {
        selectedSubjectCourse: null,
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
      createNewCBE: function(page, index) {
        this.$store.commit("currentSubjectCourseId", this.selectedSubjectCourse);
        // this.selectedSubjectCourseId = this.$refs.subjects.selectedSubjectCourse;
        // this.$store.state.currentSubjectCourseId = this.selectedSubjectCourseId;
        this.$store.state.showCBEDetails = true
        this.$store.state.showSections = false
        this.$store.state.showCBEMultipleChoiceQuestion = false
        console.log("** done")
      },
      fetchQuestionTypes: function(page, index) {
        /*
        axios
          .get("http://localhost:3000/api/v1/cbe/question_types/")
          .then(response => {
            this.$store.questionTypes = response.data;
            return response.data;
          })
          .catch(e => {
            console.log("Error" + e);
          });
          */
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
      saveNewCBE: function(page, index) {
      this.cbeDetails = {};

      // this.selectedSubjectCourseId = this.$refs.subjects.selectedSubjectCourse;
      //this.selectedSubjectCourseId = this.$refs.subjects.selectedSubject;

      this.cbeDetails["name"] = this.$store.state.cbeName;
      this.cbeDetails["description"] = this.$store.state.cbeDescription;
      this.cbeDetails["time"] = this.$store.state.cbeTimeLimit;
      this.cbeDetails["number_of_pauses"] = this.$store.state.cbeNumberOfPauses;
      this.cbeDetails["length_of_pauses"] = this.$store.state.cbeLengthOfPauses;
      this.cbeDetails["subject_course_id"] = this.selectedSubjectId;
      this.cbeDetails["title"] = this.$store.state.cbeTitle;

      this.$store.state.currentSubjectId = this.selectedSubjectCourseId;
      this.showSubjects = false;
      console.log(this.cbeDetails)
      axios
        .post("http://localhost:3000/api/cbes/create", { cbe: this.cbeDetails })
        .then(response => {
          console.log(response.status);
          this.createdCBE = response.data;
          this.$store.commit("setCurrentCbeId", this.createdCBE.cbeId);
          if (this.createdCBE.cbeId > 0) {
            this.cbeSectionButton = true;
          }
        })
        .catch(error => {
          console.log(error);
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
