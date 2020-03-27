<template>
  <div>
    <div class="row">
      <div class="col-sm-6">
        <div class="form-group">
          <label for="subjectCoursesSelect">Course</label>
          <b-form-select
            id="subjectCoursesSelect"
            v-model="subjectCourseId"
            :options="subjectCourses"
            class="input-group input-group-lg"
          >
            <template slot="first">
              <option
                :value="null"
                disabled
              >
                -- Please select a course --
              </option>
            </template>
          </b-form-select>
          <p
            v-if="!$v.subjectCourseId.required && $v.subjectCourseId.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>

      <div
        v-if="this.$store.state.cbeId"
        class="col-sm-6"
      >
        <b-form-group
          id="checkbox-input-group"
          class="mt-5 mx-4"
        >
          <b-form-checkbox
            id="active-checkbox"
            v-model="active"
          >
            Active
          </b-form-checkbox>
        </b-form-group>
      </div>

      <div class="col-sm-6">
        <div class="form-group">
          <label for="cbeName">Name</label>
          <div class="input-group input-group-lg">
            <input
              id="cbeName"
              v-model="name"
              :class="'form-control ' + {error: shouldAppendErrorClass($v.name), valid: shouldAppendValidClass($v.name)}"
              placeholder="Name"
              @blur="$v.name.$touch()"
            >
          </div>

          <p
            v-if="!$v.name.required && $v.name.$error"
            class="error-message"
          >
            field is required
          </p>
          <p
            v-if="!$v.name.alphaNum && $v.name.$error"
            class="error-message"
          >
            field should be alphanumeric.
          </p>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="cbeAgreementContent">Agreement Text</label>
          <TinyEditor
            :class="{error: shouldAppendErrorClass($v.agreementContent), valid: shouldAppendValidClass($v.agreementContent)}"
            :field-model.sync="agreementContent"
            :aditional-toolbar-options="['fullscreen code image']"
            :editor-id="'detailsEditor'"
            @blur="$v.agreementContent.$touch()"
          />
          <p
            v-if="!$v.agreementContent.required && $v.agreementContent.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>
    </div>

    <div class="row mt-3">
      <div class="col-sm-12">
        <button
          v-if="this.$store.state.cbeId"
          :disabled="updateStatus === 'PENDING'"
          class="btn btn-primary"
          @click="updateCBE"
        >
          Update CBE
        </button>
        <button
          v-else
          :disabled="submitStatus === 'PENDING' || submitStatus === 'OK'"
          class="btn btn-primary"
          @click="saveNewCBE"
        >
          Save CBE
        </button>

        <p
          v-if="updateStatus === 'ERROR'"
          class="typo__p"
        >
          Please fill the form correctly.
        </p>
        <p
          v-if="updateStatus === 'PENDING'"
          class="typo__p"
        >
          Updating...
        </p>
        <p
          v-if="submitStatus === 'ERROR'"
          class="typo__p"
        >
          Please fill the form correctly.
        </p>
        <p
          v-if="submitStatus === 'PENDING'"
          class="typo__p"
        >
          Sending...
        </p>
      </div>
    </div>
  </div>
</template>


<script>
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';
import TinyEditor from '../../TinyEditor.vue';

export default {
  components: {
    TinyEditor,
  },
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    initialName: {
      type: String,
      default: '',
    },
    initialCourseId: {
      type: Number,
      default: null,
    },
    initialAgreementContent: {
      type: String,
      default: '',
    },
    initialActive: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      name: this.initialName,
      agreementContent: this.initialAgreementContent ? this.initialAgreementContent : "<p>If you are ready to begin your exam, please click '<strong>Yes</strong>'.</p><p>If you are not ready to begin your exam, please click '<strong>No</strong>'.</p>",
      active: this.initialActive,
      subjectCourseId: this.initialCourseId,
      subjectCourses: [],
      createdCBE: [],
      submitStatus: null,
      updateStatus: null,
    };
  },
  watch: {
    initialName: {
      handler(value) {
        this.name = value;
      }
    },
    initialAgreementContent: {
      handler(value) {
        this.agreementContent = value;
      }
    },
    initialActive: {
      handler(value) {
        this.active = value;
      }
    },
    initialCourseId: {
      handler(value) {
        this.subjectCourseId = value;
      }
    },
  },
  mounted() {
    this.getSubjects();
  },
  validations: {
    subjectCourseId: {
      required,
    },
    name: {
      required,
    },
    agreementContent: {
      required,
    },
  },
  methods: {
    getSubjects() {
      axios
        .get('/api/v1/courses/')
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
        this.submitStatus = 'PENDING';
        this.cbeDetails = {};
        this.cbeDetails.name = this.name;
        this.cbeDetails.agreement_content = this.agreementContent;
        this.cbeDetails.course_id = this.subjectCourseId;
        axios
          .post('/api/v1/cbes/', { cbe: this.cbeDetails })
          .then(response => {
            this.createdCBE = response.data;
            if (this.createdCBE.id > 0) {
              this.$store.commit('setCbeId', this.createdCBE.id);
              this.$store.commit('hideDetailsForm', true);
              this.submitStatus = 'OK';
              this.$emit('close-details', this.createdCBE);
            }
          })
          .catch(error => {
            this.submitStatus = 'ERROR';
          });
      }
    },
    updateCBE() {
      const cbeId = (this.id ? this.id  : this.$store.state.cbeId);

      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = 'ERROR';
      } else {
        this.updateStatus = 'PENDING';
        this.cbeDetails = {};
        this.cbeDetails.name = this.name;
        this.cbeDetails.agreement_content = this.agreementContent;
        this.cbeDetails.active = this.active;
        this.cbeDetails.course_id = this.subjectCourseId;
        axios
          .patch(`/api/v1/cbes/${cbeId}`, {
            cbe: this.cbeDetails,
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
