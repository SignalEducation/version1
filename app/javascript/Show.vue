<template>
  <div>
    <h1> Edit CBE Details {{subjectCourses}}</h1>
    <div class="row ">

      <div class="col-sm-6">
        <div class="form-group">
          <label for="subjectCoursesSelect">Course</label>
          <b-form-select
            v-model="cbe.subject_course_id"
            :options="subjectCourses"
            id="subjectCoursesSelect"
            class="input-group input-group-lg"
          >

            <select v-model="subject_course_id">
              <option
                v-for="course in subjectCourses"
                v-bind:value="course.value"
              >
                {{ course.text }}
              </option>
            </select>

          </b-form-select>
        </div>
      </div>

      <div class="col-sm-6 ">
        <b-form-group
          id="checkbox-input-group"
          class="mt-5 mx-4"
        >
          <b-form-checkbox
            v-model="cbe.active"
            id="active-checkbox"
          >Active</b-form-checkbox>
        </b-form-group>
      </div>

    </div> <!-- row -->

    <div class="row ">
      <div class="col-sm-6">
        <label for="name">Name</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('name')"
            @click="focusField('name')"
          >{{cbe.name}}</span>
          <input
            v-model="cbe.content"
            v-show="showField('name')"
            type="name"
            class="field-value form-control"
            @focus="focusField('name')"
            @blur="blurField"
          />
        </div>
      </div>
    </div> <!-- row -->

    <div class="row ">
      <div class="col-sm-6">
        <label for="agreement_content">Agreement Content</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('agreement_content')"
            @click="focusField('agreement_content')"
          >{{cbe.agreement_content}}</span>
          <input
            v-model="cbe.agreement_content"
            v-show="showField('agreement_content')"
            id="agreement_content"
            type="text"
            class="field-value form-control"
            @focus="focusField('agreement_content')"
            @blur="blurField"
          />
        </div>
      </div>

      <div class="col-sm-6">
        <label for="exam_time">Time</label>
        <div class="field">
          <span
            class="field-value"
            v-show="!showField('exam_time')"
            @click="focusField('exam_time')"
          >{{cbe.exam_time}}</span>
          <input
            v-model="cbe.exam_time"
            v-show="showField('exam_time')"
            type="exam_time"
            class="field-value form-control"
            @focus="focusField('exam_time')"
            @blur="blurField"
          />
        </div>
      </div>
    </div> <!-- row -->

    <div class="row mt-3">
      <div class="col-sm-12">
        <!-- Save CBE -->
        <button
          v-on:click="saveForm"
          class="btn btn-primary"
        >Save</button>
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  mounted() {
    this.getSubjects();
    this.getCBEId();
    this.fetchCbe();
  },
  data() {
    return {
      cbe: {},
      editField: '',
      options: [],
      selectedCbe: '',
      cbe_id: null,
      subjectCourses: [],
      subject_course_id: null,
      active: false,
    };
  },
  methods: {
    getSubjects() {
      axios
        .get('/api/v1/subject_courses/')
        .then((response) => {
          this.subjectCourses = response.data;
          console.log(this.subjectCourses);
        })
        .catch((e) => {
          console.log(e);
        });
    },
    focusField(name) {
      this.editField = name;
    },
    blurField() {
      this.editField = '';
    },
    showField(name) {
      return this.cbe[name] === '' || this.editField === name;
    },
    // fetches all cbes
    // eslint-disable-next-line no-unused-vars
    fetchAllCbes(page, index) {
      axios
        .get('http://localhost:3000/api/v1/cbes/')
        .then((response) => {
          // this.$store.questionTypes = response.data
          this.options = response.data;
        })
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.log(`Error${e}`);
        });
    },
    getCBEId() {
      const url = document.URL;
      this.cbe_id = url.substr(url.lastIndexOf('/') + 1);
    },
    // eslint-disable-next-line no-unused-vars
    fetchCbe(page, index) {
      axios
        .get(`http://localhost:3000/api/v1/cbes/${this.cbe_id}`)
        .then((response) => {
          this.cbe = response.data;
          this.active = this.cbe;
          this.subject_course_id = this.cbe.subject_course_id;
          console.log(`**** ID **** ${response.data}`);
          // console.log(this.cbe.subject_course);
          // console.log(this.cbe);
          this.$store.commit('setCurrentCbe', this.cbe);
        })
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.log(`Error${e}`);
        });
    },

    saveForm() {
      this.$store.commit('setCurrentCbe', this.cbe);

      axios
        .patch(`http://localhost:3000/api/v1/cbes/${this.cbe_id}`, {
          cbe: this.cbe,
        })
        .then((response) => {
          this.cbe = response.data;
          this.$store.commit('setCurrentCbe', this.cbe);
          window.location.reload();
        })
        .catch((e) => {
          // eslint-disable-next-line no-console
          console.log(`Error${e}`);
        });
    },
  },
};
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
