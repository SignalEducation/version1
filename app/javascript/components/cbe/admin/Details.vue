<template>
  <div>
    <div class="row">
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
              <option :value="null" disabled>-- Please select a course --</option>
            </template>
          </b-form-select>
          <p
            v-if="!$v.subjectCourseId.required && $v.subjectCourseId.$error"
            class="error-message"
          >field is required</p>
        </div>
      </div>

      <div class="col-sm-6">
        <b-form-group id="checkbox-input-group" class="mt-5 mx-4">
          <b-form-checkbox v-model="active" id="active-checkbox">Active</b-form-checkbox>
        </b-form-group>
        <p v-if="!$v.active.required && $v.active.$error" class="error-message">field is required</p>
      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="cbeName">Name</label>
          <div class="input-group input-group-lg">
            <input
              v-model="name"
              @blur="$v.name.$touch()"
              :class="'form-control ' + {error: shouldAppendErrorClass($v.name), valid: shouldAppendValidClass($v.name)}"
              id="cbeName"
              placeholder="Name"
            />
          </div>

          <p v-if="!$v.name.required && $v.name.$error" class="error-message">field is required</p>
          <p
            v-if="!$v.name.alphaNum && $v.name.$error"
            class="error-message"
          >field should be alphanumeric.</p>
        </div>
      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="cbeExamTime">Time</label>
          <div class="input-group input-group-lg">
            <input
              v-model="examTime"
              @blur="$v.examTime.$touch()"
              :class="'form-control ' + {error: shouldAppendErrorClass($v.examTime), valid: shouldAppendValidClass($v.examTime)}"
              id="cbeExamTime"
              placeholder="Time Limit"
            />
          </div>
          <p
            v-if="!$v.examTime.required && $v.examTime.$error"
            class="error-message"
          >field is required.</p>
          <p
            v-if="!$v.examTime.numeric && $v.examTime.$error"
            class="error-message"
          >field should be numeric.</p>
          <p
            v-if="!$v.examTime.between && $v.examTime.$error"
            class="error-message"
          >must be between {{$v.examTime.$params.between.min}} and {{$v.examTime.$params.between.max}}.</p>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="cbeAgreementContent">Agreement Text</label>
          <TinyEditor
            @blur="$v.agreementContent.$touch()"
            :class="{error: shouldAppendErrorClass($v.agreementContent), valid: shouldAppendValidClass($v.agreementContent)}"
            :fieldModel.sync="agreementContent"
            :aditionalToolbarOptions="['fullscreen']"
            :editorId="'detailsEditor'"
          />
          <p
            v-if="!$v.agreementContent.required && $v.agreementContent.$error"
            class="error-message"
          >field is required</p>
        </div>
      </div>
    </div>

    <div class="row mt-3">
      <div class="col-sm-12">
        <button
          v-if="this.$store.state.cbeId"
          v-on:click="updateCBE"
          :disabled="updateStatus === 'PENDING' || updateStatus === 'OK'"
          class="btn btn-primary"
        >Update CBE</button>
        <button
          v-else
          v-on:click="saveNewCBE"
          :disabled="submitStatus === 'PENDING' || submitStatus === 'OK'"
          class="btn btn-primary"
        >Save CBE</button>

        <p class="typo__p" v-if="updateStatus === 'ERROR'">Please fill the form correctly.</p>
        <p class="typo__p" v-if="updateStatus === 'PENDING'">Updating...</p>
        <p class="typo__p" v-if="submitStatus === 'ERROR'">Please fill the form correctly.</p>
        <p class="typo__p" v-if="submitStatus === 'PENDING'">Sending...</p>
      </div>
    </div>
  </div>
</template>


<script>
import axios from "axios";
import TinyEditor from "../../TinyEditor";
import { validationMixin } from "vuelidate";
import { required, numeric, between } from "vuelidate/lib/validators";

export default {
  components: {
    TinyEditor
  },
  mixins: [validationMixin],
  mounted() {
    this.getSubjects();
  },
  props: {
    id: Number,
    initialName: String,
    initialCourseId: Number,
    initialAgreementContent: String,
    initialExamTime: Number,
    initialActive: Boolean,
  },
  data() {
    return {
      name: this.initialName,
      agreementContent: this.initialAgreementContent,
      examTime: this.initialExamTime,
      active: this.initialActive,
      subjectCourseId: this.initialCourseId,
      subjectCourses: [],
      createdCBE: [],
      submitStatus: null,
      updateStatus: null
    };
  },
  validations: {
    subjectCourseId: {
      required
    },
    active: {
      required
    },
    name: {
      required
    },
    examTime: {
      required,
      numeric,
      between: between(1, 1000)
    },
    agreementContent: {
      required
    }
  },

  methods: {
    getSubjects() {
      axios
        .get("/api/v1/subject_courses/")
        .then(response => {
          this.subjectCourses = response.data;
        })
        .catch(e => {});
    },
    saveNewCBE() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.cbeDetails = {};
        this.cbeDetails.name = this.name;
        this.cbeDetails.agreement_content = this.agreementContent;
        this.cbeDetails.exam_time = this.examTime;
        this.cbeDetails.active = this.active;
        this.cbeDetails.subject_course_id = this.subjectCourseId;
        axios
          .post("/api/v1/cbes/", { cbe: this.cbeDetails })
          .then(response => {
            this.createdCBE = response.data;
            if (this.createdCBE.id > 0) {
              this.$store.commit("setCbeId", this.createdCBE.id);
              this.$store.commit("hideDetailsForm", true);
              this.submitStatus = "OK";
              this.$emit("close-details", this.createdCBE);
            }
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    updateCBE() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = "ERROR";
      } else {
        this.cbeDetails = {};
        this.cbeDetails.name = this.name;
        this.cbeDetails.agreement_content = this.agreementContent;
        this.cbeDetails.exam_time = this.examTime;
        this.cbeDetails.active = this.active;
        this.cbeDetails.subject_course_id = this.subjectCourseId;
        axios
          .patch(`/api/v1/cbes/${this.id}`, {
            cbe: this.cbeDetails
          })

          .then(response => {
            this.createdCBE = response.data;
            if (this.createdCBE.id > 0) {
              this.$store.commit("setCbeId", this.createdCBE.id);
              this.$store.commit("hideDetailsForm", true);
              this.updateStatus = "OK";
            }
            this.$emit("close-details", this.createdCBE);
          })
          .catch(error => {
            this.updateStatus = "ERROR";
          });
      }
    },
    shouldAppendValidClass(field) {
      return !field.$invalid && field.$model && field.$dirty;
    },
    shouldAppendErrorClass(field) {
      return field.$error;
    }
  }
};
</script>
