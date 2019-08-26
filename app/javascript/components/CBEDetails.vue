<template>
  <div class="form-row form-horizontal">
    <div class="row">
      <h4>CBE Details</h4>
      <div class="col-sm-12">
        <div class="form-group">
          <label for="colFormLabelSm">Subject Course</label>
          <div class="input-group input-group-lg">
            <select v-model="cbeSubjectCourseId" class="form-control custom-select">
              <option class="col-md-8" v-for="course in subjectCourses" v-bind:value="course.id">
                {{ course.name }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="colFormLabel">Name</label>
          <div class="input-group input-group-lg">
            <input v-model="cbeName" class="form-control" id="colFormLabel" placeholder="Name" />
          </div>
        </div>

        <div class="form-group">
          <label for="colFormLabel">Time</label>
          <div class="input-group input-group-lg">
            <input v-model="cbeExamTime" class="form-control" id="colFormLabel" placeholder="Time Limit"/>
          </div>
        </div>

      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="colFormLabel">Total Score</label>
          <div class="input-group input-group-lg">
            <input v-model="cbeScore" class="form-control" id="colFormLabel" placeholder="Total Score"/>
          </div>
        </div>

        <div class="form-group">
          <label for="colFormLabel">Agreement Text</label>
          <div class="input-group input-group-lg">
            <input v-model="cbeAgreementContent" class="form-control" id="colFormLabel" placeholder="Agreement Text" />
          </div>
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
    },
    data: function() {
      return {
        cbeName: null,
        cbeExamTime: null,
        cbeAgreementContent: null,
        cbeActive: null,
        cbeScore: null,
        cbeSubjectCourseId: null,
        subjectCourses: [],
      };
    },
    methods: {
      showSubjects: function (page, index) {
        axios
          .get("/api/v1/subject_courses/")
          .then(response => {
            this.subjectCourses = response.data;
          })
          .catch(e => {
            console.log(e);

          });
      },

    },
    props: [
      "showCBEDetails",
      "selectedSubject"
    ],

    watch: {
      cbeName: function(val) {
        this.$store.commit("setCbeName", this.cbeName);
      },
      cbeAgreementContent: function(val) {
        this.$store.commit("setCbeAgreementContent", this.cbeAgreementContent);
      },
      cbeExamTime: function(val) {
        this.$store.commit("setCbeExamTime", this.cbeExamTime);
      },
      cbeScore: function(val) {
        this.$store.commit("setCbeScore", this.cbeScore);
      },
      cbeSubjectCourseId: function(val) {
        this.$store.commit("setCbeSubjectCourseId", this.cbeSubjectCourseId);
      },
    }
  };
</script>

<style lang="scss" scoped>
  input,
  output,
  textarea,
  select,
  button {
    clear: both;
    float: right;
    width: 70%;
  }

  label {
    float: left;
    width: 30%;
    text-align: right;
    padding: 0.25em 1em 0 0;
  }
</style>
