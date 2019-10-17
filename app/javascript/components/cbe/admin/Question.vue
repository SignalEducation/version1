<template>
  <div class="row">
    <div class="col-sm-4">
      <div class="form-group">
        <label for="questionKindSelect">Question Type</label>
        <b-form-select
          v-model="questionKind"
          id="questionKindSelect"
          :options="questionKinds"
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
          v-if="!$v.questionKind.required && $v.questionKind.$error"
          class="error-message"
        >
          field is required
        </p>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="form-group">
        <label for="questionScore">Score</label>
        <div class="input-group input-group-lg" id="questionScore">
          <input
            id="questionScore"
            v-model.number="questionScore"
            placeholder="Score"
            :class="
              'form-control ' +
                {
                  error: shouldAppendErrorClass($v.questionScore),
                  valid: shouldAppendValidClass($v.questionScore)
                }
            "
            @blur="$v.questionScore.$touch()"
          />
        </div>
        <p
          v-if="!$v.questionScore.required && $v.questionScore.$error"
          class="error-message"
        >
          field is required.
        </p>
        <p
          v-if="!$v.questionScore.between && $v.questionScore.$error"
          class="error-message"
        >
          must be between {{ $v.questionScore.$params.between.min }} and
          {{ $v.questionScore.$params.between.max }}.
        </p>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="form-group">
        <label for="questionSortingOrder">Sorting Order</label>
        <div class="input-group input-group-lg">
          <input
            v-model="questionSortingOrder"
            placeholder="Sorting Order"
            class="form-control"
            id="questionSortingOrder"
          />
        </div>

        <p
          v-if="!$v.questionSortingOrder.required && $v.questionSortingOrder.$error"
          class="error-message"
        >
          field is required.
        </p>
        <p
          v-if="!$v.questionSortingOrder.between && $v.questionSortingOrder.$error"
          class="error-message"
        >
          must be between {{ $v.questionSortingOrder.$params.between.min }} and
          {{ $v.questionSortingOrder.$params.between.max }}.
        </p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="questionContent">Content</label>
        <div id="questionContent">
          <TinyEditor
            :class="{
              error: shouldAppendErrorClass($v.questionContent),
              valid: shouldAppendValidClass($v.questionContent)
            }"
            :fieldModel.sync="questionContent"
            :aditionalToolbarOptions="['fullscreen code']"
            :editorId="
              'questionEditor-' + sectionId + '-' + scenarioId + '-' + id
            "
            @blur="$v.questionContent.$touch()"
          />
          <p
            v-if="!$v.questionContent.required && $v.questionContent.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>
    </div>

    <div class="col-sm-12">
      <AdminAnswers
        :question_kind="questionKind"
        :answers="questionAnswers"
        v-model="questionAnswers"
      />
    </div>

    <div class="form-group">
      <button
        v-if="id"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="updateQuestion"
      >
        Update Question
      </button>
      <button
        v-else
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="saveQuestion"
      >
        Save Question
      </button>
      <p v-if="submitStatus === 'ERROR'" class="typo__p">
        Please fill the form correctly.
      </p>
      <p v-if="submitStatus === 'PENDING'" class="typo__p">
        Sending...
      </p>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required, numeric, between } from 'vuelidate/lib/validators';

import TinyEditor from '../../TinyEditor.vue';
import AdminAnswers from './QuestionAnswers.vue';

export default {
  props: {
    sectionId: {
      type: Number,
      default: null
    },
    scenarioId: {
      type: Number,
      default: null
    },
    id: {
      type: Number,
      default: null
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
    initialAnswers: {
      type: Array,
      default: () => []
    }
  },
  components: {
    TinyEditor,
    AdminAnswers,
  },
  mixins: [validationMixin],
  data: function() {
    return {
      questionDetails: {},
      questionKind: this.initialKind,
      questionContent: this.initialContent,
      questionScore: this.initialScore,
      questionSortingOrder: this.initialSortingOrder,
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
    questionSortingOrder: {
      required,
      numeric,
      between: between(1, 10)
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
        this.questionDetails.sorting_order = this.questionSortingOrder;
        this.questionDetails.answers_attributes = this.questionAnswers;
        this.questionDetails.cbe_section_id = this.sectionId;
        this.questionDetails.cbe_scenario_id = this.scenarioId;
        const url = this.scenarioId
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
            this.questionSortingOrder = null;
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
        this.questionDetails.sorting_order = this.questionSortingOrder;
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
            this.questionSortingOrder = this.initialSortingOrder;
            this.submitStatus = "OK";
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    shouldAppendValidClass(field) {
      if (typeof field !== "undefined") {
        return !field.$invalid && field.$model && field.$dirty;
      }
    },
    shouldAppendErrorClass(field) {
      if (typeof field !== "undefined") {
        return field.$error;
      }
    }
  }
};
</script>
