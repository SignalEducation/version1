<template>
  <section>
    <div style="padding: 15px">
      <ul class="flex-container">
        <li
          v-if="totalQuestions > 1"
          @click="prevPage"
          class="lightgrey nav-ques-arrow"
        >
          &laquo;
        </li>
        <li v-else class="lightgrey nav-ques-arrow-shw">&raquo;</li>
        <li class="flex-item">
          Question {{ this.activePage }} of {{ totalQuestions }}
        </li>
        <li
          v-if="this.activePage < totalQuestions && totalQuestions > 1"
          @click="nextPage(totalQuestions)"
          class="lightgrey nav-ques-arrow"
        >
          &raquo;
        </li>
        <li v-else class="lightgrey nav-ques-arrow-shw">&raquo;</li>
      </ul>

      <div class="prac-ques-ans-box">
        <div v-if="questionContent.kind == 'open'">
          <TinyEditor
            :field-model.sync="questionContent.content"
            :aditional-toolbar-options="[]"
            :editor-id="`${questionContent.id}`"
            :key="questionContent.id"
            @blur="$v.questionContent.$touch()"
          />
        </div>

        <div v-if="questionContent.kind == 'spreadsheet'">
          <spreadsheet-editor
            :initial-data="questionContent.content"
            :key="questionContent.id"
            @spreadsheet-updated="syncSpreadsheetData"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import axios from "axios";
import eventBus from "../cbe/EventBus.vue";
import TinyEditor from "../TinyEditor.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
    TinyEditor,
  },
  props: {
    totalQuestions: {
      type: Number,
    },
    questionContentArray: {
      type: Array,
    },
    answerContentArray: {
      type: Array,
    },
    stepLogId: {
      type: String,
      Number,
    },
  },
  data() {
    return {
      modalIsOpen: false,
      activePage: 1,
      isActive: true,
      questionContent: null,
    };
  },
  async created() {
    this.questionContent = this.questionContentArray[this.activePage - 1];
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    changePage: function(num) {
      this.activePage = num;
    },
    nextPage: function(lastQuestion) {
      if (this.activePage < lastQuestion) this.activePage++;
    },
    prevPage: function() {
      if (this.activePage > 1) this.activePage--;
    },
    syncSpreadsheetData(jsonData) {
      this.questionContent.content = { data: jsonData };
    },
    updateCurrentAnswer: function(index) {
      const lastQuestion = this.questionContentArray[index - 1];

      axios
        .patch(
          `/api/v1/practice_questions/${lastQuestion.practice_question_id}/`,
          {
            practice_questions: lastQuestion,
            step_log: this.stepLogId,
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
    answersContent: function(index) {},
  },
  watch: {
    activePage: function(newVal, oldVal) {
      eventBus.$emit("active-solution-index", newVal - 1);

      this.questionContent = this.questionContentArray[this.activePage - 1];
      this.updateCurrentAnswer(oldVal);
    },
  },
};
</script>
