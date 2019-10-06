<template>
  <div class="row">
    <div class="col-sm-6">
      <div class="form-group">
        <label for="questionKindSelect">Question Type</label>
        <b-form-select
          v-model="questionKind"
          :options="questionKinds"
          id="questionKindSelect"
          class="input-group input-group-lg"
        >
          <template slot="first">
            <option :value="null" disabled>-- Please select a type --</option>
          </template>
        </b-form-select>
        <p
          v-if="!$v.questionKind.required && $v.questionKind.$error"
          class="error-message"
        >field is required</p>
      </div>
    </div>

    <div class="col-sm-6">
      <div class="form-group">
        <label for="questionScore">Score</label>
        <div class="input-group input-group-lg" id="questionScore">
          <input
            v-model="questionScore"
            @blur="$v.questionScore.$touch()"
            :class="'form-control ' + {error: shouldAppendErrorClass($v.questionScore), valid: shouldAppendValidClass($v.questionScore)}"
            id="questionScore"
            placeholder="Score"
          />
        </div>
        <p
          v-if="!$v.questionScore.required && $v.questionScore.$error"
          class="error-message"
        >field is required.</p>
        <p
          v-if="!$v.questionScore.between && $v.questionScore.$error"
          class="error-message"
        >must be between {{$v.questionScore.$params.between.min}} and {{$v.questionScore.$params.between.max}}.</p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="questionContent">Content</label>
        <div class="input-group input-group-lg" id="questionContent">
          <TinyEditor
            @blur="$v.questionContent.$touch()"
            :class="{error: shouldAppendErrorClass($v.questionContent), valid: shouldAppendValidClass($v.questionContent)}"
            :fieldModel.sync="questionContent"
            :aditionalToolbarOptions="['fullscreen']"
            :editorId="'questionEditor-' + sectionId + '-' + scenarioId + '-' + id"
          />
          <p
            v-if="!$v.questionContent.required && $v.questionContent.$error"
            class="error-message"
          >field is required</p>
        </div>
      </div>
    </div>

    <div class="col-sm-12">
      <AdminAnswers
        :question_kind="questionKind"
        :answers="this.questionAnswers"
        v-model="questionAnswers"
      />
    </div>

    <div class="form-group">
      <button
        v-if="id"
        v-on:click="updateQuestion"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
      >Update Question</button>
      <button
        v-else
        v-on:click="saveQuestion"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
      >Save Question</button>
      <p class="typo__p" v-if="submitStatus === 'ERROR'">Please fill the form correctly.</p>
      <p class="typo__p" v-if="submitStatus === 'PENDING'">Sending...</p>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import TinyEditor from "../../TinyEditor";
import AdminAnswers from "./QuestionAnswers";
import { validationMixin } from "vuelidate";
import { required, numeric, between } from "vuelidate/lib/validators";

export default {
  props: {
    sectionId: Number,
    scenarioId: Number,
    id: {
      type: Number,
      default: 0
    },
    initialScore: String,
    initialContent: String,
    initialKind: String,
    initialAnswers: Array
  },
  components: {
    TinyEditor,
    AdminAnswers
  },
  mixins: [validationMixin],
  data: function() {
    return {
      questionDetails: {},
      questionKind: this.initialKind,
      questionContent: this.initialContent,
      questionScore: this.initialScore,
      questionAnswers: this.initialAnswers || [],
      selectedSelectQuestion: null,
      questionKinds: [
        "multiple_choice",
        "multiple_response",
        "complete",
        "fill_in_the_blank",
        "drag_drop",
        "dropdown_list",
        "hot_spot",
        "spreadsheet",
        "open"
      ],
      submitStatus: null
    };
  },
  validations: {
    questionKind: {
      required
    },
    questionScore: {
      required,
      numeric,
      between: between(1, 100)
    },
    questionContent: {
      required
    }
  },
  methods: {
    saveQuestion(page, index) {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.questionDetails = {};
        this.questionDetails.kind = this.questionKind;
        this.questionDetails.content = this.questionContent;
        this.questionDetails.score = this.questionScore;
        this.questionDetails.answers_attributes = this.questionAnswers;
        this.questionDetails.cbe_section_id = this.sectionId;
        this.questionDetails.cbe_scenario_id = this.scenarioId;
        let url = this.scenarioId
          ? `/api/v1/scenarios/${this.scenarioId}/questions/`
          : `/api/v1/sections/${this.sectionId}/questions/`;

        axios
          .post(url, {
            question: this.questionDetails
          })
          .then(response => {
            this.createdQuestion = response.data;
            this.questionDetails.id = this.createdQuestion.id;
            this.$emit("add-question", this.questionDetails);
            this.$emit("update-content", this.TinyEditor);
            this.questionDetails = {};
            this.questionKind = null;
            this.questionContent = null;
            this.questionScore = null;
            this.questionAnswers = [];
            this.submitStatus = "OK";
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    updateQuestion: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.questionDetails = {};
        this.questionDetails.kind = this.questionKind;
        this.questionDetails.content = this.questionContent;
        this.questionDetails.score = this.questionScore;
        this.questionDetails.cbe_section_id = this.sectionId;
        this.questionDetails.cbe_scenario_id = this.scenarioId;
        this.questionDetails.answers_attributes = this.questionAnswers;

        axios
          .patch(`/api/v1/questions/${this.id}`, {
            question: this.questionDetails
          })
          .then(response => {
            this.updatedQuestion = response.data;
            this.questionDetails["id"] = this.updatedQuestion.id;
            this.$emit("update-content", this.TinyEditor);
            this.questionDetails = {};
            this.questionKind = this.initialKind;
            this.questionContent = this.initialContent;
            this.questionScore = this.initialScore;
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
