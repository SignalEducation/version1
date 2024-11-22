<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionName">Name</label>
        <div class="input-group input-group-lg">
          <input
            id="sectionName"
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
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionKindSelect">Section Type</label>
        <b-form-select
          id="sectionKindSelect"
          v-model="kind"
          :options="sectionKinds"
          @change="onChangeKind($event)"
          class="input-group input-group-lg"
        >
          <template slot="first">
            <option
              :value="null"
              disabled
            >
              -- Please select a type --
            </option>
          </template>
        </b-form-select>
        <p
          v-if="!$v.kind.required && $v.kind.$error"
          class="error-message"
        >
          field is required
        </p>
      </div>

      <div class="form-group" v-if="showRandom">
        <b-form-group
          id="checkbox-input-group"

        >
          <b-form-checkbox
            v-model="random"
          >
            Randomize Questions?
          </b-form-checkbox>
        </b-form-group>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="sectionScore">Score</label>
        <div class="input-group input-group-lg">
          <input
            id="sectionScore"
            v-model="score"
            :class="'form-control ' + {error: shouldAppendErrorClass($v.score), valid: shouldAppendValidClass($v.score)}"
            placeholder="Score"
            type="decimal"
            @blur="$v.score.$touch()"
          >
        </div>
        <p
          v-if="!$v.score.required && $v.score.$error"
          class="error-message"
        >
          field is required.
        </p>
        <p
          v-if="!$v.score.between && $v.score.$error"
          class="error-message"
        >
          must be between {{ $v.score.$params.between.min }} and {{ $v.score.$params.between.max }}.
        </p>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="sortingOrder">Sorting Order</label>
        <div class="input-group input-group-lg">
          <input
            id="sortingOrder"
            v-model="sortingOrder"
            placeholder="Sorting Order"
            class="form-control"
            type="number"
          >
        </div>

        <p
          v-if="!$v.sortingOrder.required && $v.sortingOrder.$error"
          class="error-message"
        >
          field is required.
        </p>
        <p
          v-if="!$v.sortingOrder.between && $v.sortingOrder.$error"
          class="error-message"
        >
          must be between {{ $v.sortingOrder.$params.between.min }} and {{ $v.sortingOrder.$params.between.max }}.
        </p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group section-content-field">
        <label for="sectionContent">Cover Page Content</label>
        <TinyEditor
          :class="{error: shouldAppendErrorClass($v.content), valid: shouldAppendValidClass($v.content)}"
          :field-model.sync="content"
          :aditional-toolbar-options="['fullscreen code image']"
          :editor-id="'sectionEditor' + id"
          @blur="$v.content.$touch()"
        />
        <p
          v-if="!$v.content.required && $v.content.$error"
          class="error-message"
        >
          field is required
        </p>
      </div>
    </div>

    <div>
      <button
        v-if="id"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="updateSection"
      >
        Update Section
      </button>
      <button
        v-if="id"
        class="btn btn-danger"
        @click="deleteSection"
      >
        Delete Section
      </button>
      <button
        v-else
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="saveSection"
      >
        Save Section
      </button>
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
</template>

<script>
import axios from "axios";
import { validationMixin } from "vuelidate";
import { required, numeric, decimal, between } from "vuelidate/lib/validators";
import TinyEditor from "../../TinyEditor.vue";

export default {
  components: {
    TinyEditor
  },
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    initialName: {
      type: String,
      default: ""
    },
    initialScore: {
      type: Number,
      default: null
    },
    initialSortingOrder: {
      type: Number,
      default: 1
    },
    initialContent: {
      type: String,
      default: ""
    },
    initialKind: {
      type: String,
      default: ""
    },
    initialRandom: {
      type: Boolean,
      default: false
    },
  },
  data() {
    return {
      sectionDetails: {},
      name: this.initialName,
      score: this.initialScore,
      sortingOrder: this.initialSortingOrder,
      kind: this.initialKind,
      content: this.initialContent,
      sectionKinds: [
         { value: 'objective', text: 'Objective' },
         { value: 'objective_test_case', text: 'Objective Test Case' },
         { value: 'constructed_response', text: 'Constructed Response' },
         { value: 'exhibits_scenario', text: 'Exhibits Scenario' }
      ],
      random: this.initialRandom,
      showRandom: this.initialKind == "objective" ? true : false,
      submitStatus: null,
      deleteStatus: null
    };
  },
  validations: {
    kind: {
      required
    },
    name: {
      required
    },
    score: {
      required,
      decimal,
      between: between(1, 1000)
    },
    sortingOrder: {
      required,
      numeric,
    },
    content: {
      required
    }
  },
  methods: {
    saveSection() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.sectionDetails.name = this.name;
        this.sectionDetails.score = this.score;
        this.sectionDetails.sorting_order = this.sortingOrder;
        this.sectionDetails.kind = this.kind;
        this.sectionDetails.random = this.random;
        this.sectionDetails.content = this.content;
        this.sectionDetails.cbe_id = this.$store.state.cbeId;

        axios
          .post(`/api/v1/cbes/${this.$store.state.cbeId}/sections`, {
            cbe_section: this.sectionDetails
          })
          .then(response => {
            this.createdSection = response.data;
            if (this.createdSection.id > 0) {
              this.sectionDetails.id = this.createdSection.id;
              this.$emit("add-section", this.sectionDetails);
              this.$emit("update-content", this.TinyEditor);
              this.sectionDetails = {};
              this.name = this.initialName;
              this.kind = this.initialKind;
              this.random = this.initialKind == "objective" ? true : false;
              this.score = this.initialScore;
              this.sortingOrder += 1;
              this.content = null;
              this.submitStatus = "OK";
              this.$v.$reset();
            }
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    updateSection() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.sectionDetails.name = this.name;
        this.sectionDetails.score = this.score;
        this.sectionDetails.sorting_order = this.sortingOrder;
        this.sectionDetails.kind = this.kind;
        this.sectionDetails.random = this.random;
        this.sectionDetails.content = this.content;
        this.sectionDetails.cbe_id = this.$store.state.cbeId;

        axios
          .patch(`/api/v1/sections/${this.id}`, {
            cbe_section: this.sectionDetails
          })
          .then(response => {
            this.updatedSection = response.data;
            this.sectionDetails.id = this.updatedSection.id;
            this.$emit("update-content", this.TinyEditor);
            this.sectionDetails = {};
            this.name = this.updatedSection.name;
            this.content = this.updatedSection.content;
            this.score = this.updatedSection.score;
            this.sortingOrder = this.updatedSection.sorting_order;
            this.kind = this.updatedSection.kind;
            this.random = this.updatedSection.random;
            this.submitStatus = "OK";
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    deleteSection() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';
          const sectionId = this.id;

          axios
            .delete(`/api/v1/sections/${sectionId}`)
            .then(response => {
              this.$emit('rm-section', sectionId);
              this.updateStatus = 'OK';
              this.$v.$reset();
            })
            .catch(error => {
              this.updateStatus = 'ERROR';
              console.log(error);
            });
        }
      }
    },
    shouldAppendValidClass(field) {
      return !field.$invalid && field.$model && field.$dirty;
    },
    shouldAppendErrorClass(field) {
      return field.$error;
    },
    onChangeKind(kind) {
      this.random = false
      this.showRandom = kind == "objective" ? true : false
    }
  }
};
</script>
