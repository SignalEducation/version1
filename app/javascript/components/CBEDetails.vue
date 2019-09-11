<template>
  <div>
    <h4>CBE Details</h4>
    <div class="row ">

      <div class="col-sm-6">
        <div class="form-group">
          <label for="subjectCoursesSelect">Course</label>
          <b-form-select
            v-model="subjectCourseId"
            :options="subjectCourses"
            id="subjectCoursesSelect"
            class="input-group input-group-lg"
          >
            <template slot="first">
              <option
                :value="null"
                disabled
              >-- Please select a course --</option>
            </template>
          </b-form-select>
        </div>
      </div>

      <div class="col-sm-6 ">
        <b-form-group
          id="checkbox-input-group"
          class="mt-5 mx-4"
        >
          <b-form-checkbox
            v-model="active"
            id="active-checkbox"
          >Active</b-form-checkbox>
        </b-form-group>
      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="cbeName">Name</label>
          <div class="input-group input-group-lg">
            <input
              v-model="name"
              class="form-control"
              id="cbeName"
              placeholder="Name"
            />
          </div>
        </div>
      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="cbeExamTime">Time</label>
          <div class="input-group input-group-lg">
            <input
              v-model="examTime"
              class="form-control"
              id="cbeExamTime"
              placeholder="Time Limit"
            />
          </div>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="cbeAgreementContent">Agreement Text</label>
          <div class="input-group input-group-lg">
            <textarea
              v-model="agreementContent"
              class="form-control"
              id="cbeAgreementContent"
              placeholder="Agreement Text"
            ></textarea>
          </div>
        </div>
      </div>

    </div>

    <div class="row mt-3">
      <div class="col-sm-12">
        <!-- Save CBE -->
        <button
          v-on:click="saveNewCBE"
          class="btn btn-primary"
        >Save CBE</button>
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  mounted() {
    this.getSubjects();
  },
  data() {
    return {
      name: null,
      agreementContent: null,
      examTime: null,
      active: false,
      subjectCourseId: null,
      subjectCourses: [],
      createdCBE: [],
    };
  },
  watch: {
    name() {
      this.$store.commit('setCbeName', this.name);
    },
    agreementContent() {
      this.$store.commit('setCbeAgreementContent', this.agreementContent);
    },
    examTime() {
      this.$store.commit('setCbeExamTime', this.examTime);
    },
    subjectCourseId() {
      this.$store.commit('setCbeSubjectCourseId', this.subjectCourseId);
    },
    active() {
      this.$store.commit('setCbeActive', this.active);
    },
  },
  methods: {
    getSubjects() {
      axios
        .get('/api/v1/subject_courses/')
        .then((response) => {
          this.subjectCourses = response.data;
        })
        .catch((e) => {
          console.log(e);
        });
    },
    saveNewCBE() {
      this.cbeDetails = {};
      this.cbeDetails.name = this.$store.state.cbeDetails.cbeName;
      this.cbeDetails.agreement_content = this.$store.state.cbeDetails.cbeAgreementContent;
      this.cbeDetails.exam_time = this.$store.state.cbeDetails.cbeExamTime;
      this.cbeDetails.active = this.$store.state.cbeDetails.cbeActive;
      this.cbeDetails.subject_course_id = this.$store.state.cbeDetails.cbeSubjectCourseId;

      axios
        .post('/api/v1/cbes/', { cbe: this.cbeDetails })
        .then((response) => {
          this.createdCBE = response.data;
          if (this.createdCBE.id > 0) {
            this.$store.commit('setCbeId', this.createdCBE.id);
            this.$store.commit('hideDetailsForm', true);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
  },
};
</script>
