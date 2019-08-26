<template>
  <div>


  </div>
</template>
  
<script>
  import axios from "axios";

  export default {
    mounted() {
      this.showSubjects();
      // this.fetchQuestionTypes();
      // this.fetchQuestionStatuses();
      // this.fetchSectionTypes()
    },
    data: function() {
      return {
        selectedSubjectCourse: null,
        questionTypes: [],
        subjectCourses: [],
      };
    },
    methods: {
      showSubjects: function(page, index) {
        axios
          .get("/api/v1/subject_courses/")
          .then(response => {
            this.subjectCourses = response.data;
          })
          .catch(e => {
            console.log(e);

          });
      },

      createNewCBE: function(page, index) {
        this.$store.commit("currentSubjectCourseId", this.selectedSubjectCourse);
        this.$store.state.showCBEDetails = true;
        this.$store.state.showSections = false;
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

      saveNewCBE: function(page, index) {
        this.cbeDetails = {};

        this.selectedSubjectCourseId = this.$refs.subjects.selectedSubjectCourse;

        this.cbeDetails["name"] = this.$store.state.cbeName;
        this.cbeDetails["agreement_content"] = this.$store.state.cbeAgreementContent;
        this.cbeDetails["exam_time"] = this.$store.state.cbeExamTime;
        this.cbeDetails["score"] = this.$store.state.cbeScore;
        this.cbeDetails["subject_course_id"] = this.selectedSubjectId;

        this.$store.state.currentSubjectId = this.selectedSubjectCourseId;
        this.showSubjects = false;
        console.log(this.cbeDetails);
        axios
          .post("http://localhost:3000/api/v1/cbes/", { cbe: this.cbeDetails })
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
