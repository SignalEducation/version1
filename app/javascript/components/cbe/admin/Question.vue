<template>
  <div class="row">
    <div class="col-sm-4">
      <div class="form-group">
        <label for="questionKindSelect">Question Type</label>
        <b-form-select
          id="questionKindSelect"
          v-model="questionKind"
          :options="questionKinds"
          class="input-group input-group-lg"
          @change="resetAnwers()"
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
        <div
          id="questionScore"
          class="input-group input-group-lg"
        >
          <input
            id="questionScore"
            v-model.number="questionScore"
            placeholder="Score"
            type="number"
            :class="
              'form-control ' +
                {
                  error: shouldAppendErrorClass($v.questionScore),
                  valid: shouldAppendValidClass($v.questionScore),
                }
            "
            @blur="$v.questionScore.$touch()"
          >
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
            id="questionSortingOrder"
            v-model="questionSortingOrder"
            type="number"
            placeholder="Sorting Order"
            class="form-control"
          >
        </div>

        <p
          v-if="
            !$v.questionSortingOrder.required && $v.questionSortingOrder.$error
          "
          class="error-message"
        >
          field is required.
        </p>
        <p
          v-if="
            !$v.questionSortingOrder.between && $v.questionSortingOrder.$error
          "
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
              valid: shouldAppendValidClass($v.questionContent),
            }"
            :field-model.sync="questionContent"
            :aditional-toolbar-options="['fullscreen code']"
            :editor-id="
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
      <div class="form-group">
        <label for="questionSolution">Solution</label>
        <div id="questionSolution">
          <TinyEditor
            :field-model.sync="questionSolution"
            :aditional-toolbar-options="['fullscreen code']"
            :editor-id="
              'questionSolution-' + sectionId + '-' + scenarioId + '-' + id
            "
            @blur="$v.questionSolution.$touch()"
          />
        </div>
      </div>
    </div>

    <div class="col-sm-12">
      <AdminAnswers
        v-model="questionAnswers"
        :question-kind="questionKind"
        :question-id="id"
        :answers="questionAnswers"
        :validate-data="$v"
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
        v-if="id"
        class="btn btn-danger"
        @click="deleteQuestion"
      >
        Delete Question
      </button>
      <button
        v-else
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="saveQuestion"
      >
        Save Question
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
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required, numeric, between } from 'vuelidate/lib/validators';

import TinyEditor from '../../TinyEditor.vue';
import AdminAnswers from './QuestionAnswers.vue';

export default {
  components: {
    TinyEditor,
    AdminAnswers,
  },
  mixins: [validationMixin],
  props: {
    sectionId: {
      type: Number,
      default: null,
    },
    scenarioId: {
      type: Number,
      default: null,
    },
    id: {
      type: Number,
      default: null,
    },
    initialScore: {
      type: Number,
      default: null,
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    initialContent: {
      type: String,
      default: '',
    },
    initialSolution: {
      type: String,
      default: '',
    },
    initialKind: {
      type: String,
      default: '',
    },
    initialAnswers: {
      type: Array,
      default: () => [],
    },
  },
  data() {
    return {
      questionDetails: {},
      questionKind: this.initialKind,
      questionContent: this.initialContent,
      questionSolution: this.initialSolution,
      questionScore: this.initialScore,
      questionSortingOrder: this.initialSortingOrder,
      questionAnswers: this.initialAnswers || [],
      selectedSelectQuestion: null,
      questionKinds: [
        'dropdown_list',
        'fill_in_the_blank',
        'multiple_choice',
        'multiple_response',
        'spreadsheet',
        'open',
      ],
      submitStatus: null,
      deleteStatus: null,
    };
  },
  validations: {
    questionKind: {
      required,
    },
    questionScore: {
      required,
      numeric,
      between: between(1, 100),
    },
    questionSortingOrder: {
      required,
      numeric,
    },
    questionContent: {
      required,
    },
    questionAnswers: {
      answersRequired() {
        let check = false;

        switch (this.questionKind) {
          case 'dropdown_list':
          case 'multiple_choice':
          case 'multiple_response':
            check = this.questionAnswers.length > 0;
            break;
          default:
            check = true;
        }

        return check;
      },
      setCorrectAnswerRequired() {
        let check = false;

        switch (this.questionKind) {
          case 'dropdown_list':
          case 'multiple_choice':
          case 'multiple_response':
            check = this.questionAnswers
              .map(function(answer) {
                return answer.content.correct;
              })
              .includes(true);
            break;
          default:
            check = true;
        }

        return check;
      },
    },
  },
  methods: {
    saveQuestion() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        this.questionDetails = {};
        this.questionDetails.kind = this.questionKind;
        this.questionDetails.content = this.questionContent;
        this.questionDetails.solution = this.questionSolution;
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
            question: this.questionDetails,
          })
          .then(response => {
            this.createdQuestion = response.data;
            this.questionDetails.id = this.createdQuestion.id;
            this.questionDetails.answers_attributes = this.createdQuestion.answers;
            this.$emit('add-question', this.questionDetails);
            this.$emit('update-content', this.TinyEditor);
            this.questionDetails = {};
            this.questionKind = null;
            this.questionContent = null;
            this.questionSolution = null;
            this.questionScore = null;
            this.questionSortingOrder += 1;
            this.questionAnswers = [];
            this.submitStatus = 'OK';
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = 'ERROR';
          });
      }
    },
    updateQuestion() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        this.questionDetails = {};
        this.questionDetails.kind = this.questionKind;
        this.questionDetails.content = this.questionContent;
        this.questionDetails.solution = this.questionSolution;
        this.questionDetails.score = this.questionScore;
        this.questionDetails.sorting_order = this.questionSortingOrder;
        this.questionDetails.cbe_section_id = this.sectionId;
        this.questionDetails.cbe_scenario_id = this.scenarioId;
        this.questionDetails.answers_attributes = this.questionAnswers;

        axios
          .patch(`/api/v1/questions/${this.id}`, {
            question: this.questionDetails,
          })
          .then(response => {
            this.updatedQuestion = response.data;
            this.questionDetails.id = this.updatedQuestion.id;
            this.$emit('update-content', this.TinyEditor);
            this.questionDetails = {};
            this.questionKind = this.initialKind;
            this.questionContent = this.initialContent;
            this.questionSolution = this.initialSolution;
            this.questionScore = this.initialScore;
            this.questionSortingOrder = this.initialSortingOrder;
            this.submitStatus = 'OK';
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = 'ERROR';
          });
      }
    },
    deleteQuestion() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';
          const questionId = this.id;

          axios
            .delete(`/api/v1/questions/${questionId}`)
            .then(response => {
              this.$emit('rm-question', questionId);
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
      if (typeof field !== 'undefined') {
        return !field.$invalid && field.$model && field.$dirty;
      }
    },
    shouldAppendErrorClass(field) {
      if (typeof field !== 'undefined') {
        return field.$error;
      }
    },
    resetAnwers() {
      this.questionAnswers = [];
    },
  },
};
</script>
