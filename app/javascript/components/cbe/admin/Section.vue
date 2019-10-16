<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionName">Name</label>
        <div class="input-group input-group-lg">
          <input
            v-model="name"
            @blur="$v.name.$touch()"
            :class="'form-control ' + {error: shouldAppendErrorClass($v.name), valid: shouldAppendValidClass($v.name)}"
            id="sectionName"
            placeholder="Name"
          />
        </div>
        <p v-if="!$v.name.required && $v.name.$error" class="error-message">field is required</p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionKindSelect">Section Type</label>
        <b-form-select
          v-model="kind"
          :options="sectionKinds"
          id="sectionKindSelect"
          class="input-group input-group-lg"
        >
          <template slot="first">
            <option :value="null" disabled>-- Please select a type --</option>
          </template>
        </b-form-select>
        <p v-if="!$v.kind.required && $v.kind.$error" class="error-message">field is required</p>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="sectionScore">Score</label>
        <div class="input-group input-group-lg">
          <input
            v-model="score"
            @blur="$v.score.$touch()"
            :class="'form-control ' + {error: shouldAppendErrorClass($v.score), valid: shouldAppendValidClass($v.score)}"
            id="sectionScore"
            placeholder="Score"
          />
        </div>
        <p v-if="!$v.score.required && $v.score.$error" class="error-message">field is required.</p>
        <p
          v-if="!$v.score.between && $v.score.$error"
          class="error-message"
        >must be between {{$v.score.$params.between.min}} and {{$v.score.$params.between.max}}.</p>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="sortingOrder">Sorting Order</label>
        <div class="input-group input-group-lg">
          <input v-model="sortingOrder" placeholder="Sorting Order" class="form-control" id="sortingOrder" />
        </div>

        <p v-if="!$v.sortingOrder.required && $v.sortingOrder.$error" class="error-message">field is required.</p>
      <p
        v-if="!$v.sortingOrder.between && $v.sortingOrder.$error"
        class="error-message"
      >must be between {{$v.sortingOrder.$params.between.min}} and {{$v.sortingOrder.$params.between.max}}.</p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionContent">Cover Page Content</label>
        <TinyEditor
          @blur="$v.content.$touch()"
          :class="{error: shouldAppendErrorClass($v.content), valid: shouldAppendValidClass($v.content)}"
          :fieldModel.sync="content"
          :aditionalToolbarOptions="['fullscreen code']"
          :editorId="'sectionEditor' + id"
        />
        <p v-if="!$v.content.required && $v.content.$error" class="error-message">field is required</p>
      </div>
    </div>

    <div>
      <button
        v-if="id"
        @click="updateSection"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
      >Update Section</button>
      <button
        v-else
        @click="saveSection"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
      >Save Section</button>
      <p class="typo__p" v-if="submitStatus === 'ERROR'">Please fill the form correctly.</p>
      <p class="typo__p" v-if="submitStatus === 'PENDING'">Sending...</p>
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
  props: {
    id: Number,
    initialName: {
      type: String,
      default: ""
    },
    initialScore: Number,
    initialSortingOrder: {
      type: Number,
      default: 1
    },
    initialContent: String,
    initialKind: String
  },
  data: function() {
    return {
      sectionDetails: {},
      name: this.initialName,
      score: this.initialScore,
      sortingOrder: this.initialSortingOrder,
      kind: this.initialKind,
      content: this.initialContent,
      sectionKinds: [
        "objective",
        "objective_test_case",
        "constructed_response"
      ],
      submitStatus: null
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
      numeric,
      between: between(1, 1000)
    },
    sortingOrder: {
      required,
      numeric,
      between: between(1, 10)
    },
    content: {
      required
    }
  },
  methods: {
    saveSection: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.sectionDetails["name"] = this.name;
        this.sectionDetails["score"] = this.score;
        this.sectionDetails["sorting_order"] = this.sortingOrder;
        this.sectionDetails["kind"] = this.kind;
        this.sectionDetails["content"] = this.content;
        this.sectionDetails["cbe_id"] = this.$store.state.cbeId;

        axios
          .post(`/api/v1/cbes/${this.$store.state.cbeId}/sections`, {
            cbe_section: this.sectionDetails
          })
          .then(response => {
            this.createdSection = response.data;
            if (this.createdSection.id > 0) {
              this.sectionDetails["id"] = this.createdSection.id;
              this.$emit("add-section", this.sectionDetails);
              this.$emit("update-content", this.TinyEditor);
              this.sectionDetails = {};
              this.name = this.initialName;
              this.kind = this.initialKind;
              this.score = this.initialScore;
              this.sortingOrder = this.initialSortingOrder;
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
    updateSection: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.sectionDetails["name"] = this.name;
        this.sectionDetails["score"] = this.score;
        this.sectionDetails["sorting_order"] = this.sortingOrder;
        this.sectionDetails["kind"] = this.kind;
        this.sectionDetails["content"] = this.content;
        this.sectionDetails["cbe_id"] = this.$store.state.cbeId;

        axios
          .patch(`/api/v1/sections/${this.id}`, {
            cbe_section: this.sectionDetails
          })
          .then(response => {
            this.updatedSection = response.data;
            this.sectionDetails["id"] = this.updatedSection.id;
            //this.$emit('add-section', this.sectionDetails);
            this.$emit("update-content", this.TinyEditor);
            this.sectionDetails = {};
            this.name = this.updatedSection.name;
            this.content = this.updatedSection.content;
            this.score = this.updatedSection.score;
            this.sortingOrder = this.updatedSection.sorting_order;
            this.kind = this.updatedSection.kind;
            this.submitStatus = "OK";
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = "ERROR";
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
