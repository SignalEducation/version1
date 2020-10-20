<template>
  <section>
    <div style="padding:15px;">
      <ul class="flex-container">
        <li v-if="totalQuestions > 1" @click="prevPage" class="lightgrey nav-ques-arrow"> &laquo; </li>
        <li v-else class="lightgrey nav-ques-arrow-shw"> &raquo; </li>
        <li class="flex-item">Question {{this.activePage}} of {{totalQuestions}}</li>
        <li v-if="this.activePage < totalQuestions && totalQuestions > 1" @click="nextPage(totalQuestions)" class="lightgrey nav-ques-arrow"> &raquo; </li>
        <li v-else class="lightgrey nav-ques-arrow-shw"> &raquo; </li>
      </ul>
      <p v-html="questionContentArray[this.activePage-1].content"></p>
      <div class="prac-ques-ans-box">
        <div v-show="questionContentArray[this.activePage-1].kind == 'open'">
          <OpenAnswer :question-id="questionContentArray[this.activePage-1].id" />
        </div>
        <div v-show="questionContentArray[this.activePage-1].kind == 'spreadsheet'">
          <SpreadsheetEditor
            :initial-data="answerContentArray[this.activePage-1].content"
            @spreadsheet-updated="syncSpreadsheetData"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<script>

import OpenAnswer from "../cbe/answers/OpenAnswer.vue"
import SpreadsheetAnswer from "../cbe/answers/SpreadsheetAnswer.vue"
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus,
    OpenAnswer,
    SpreadsheetAnswer,
    SpreadsheetEditor
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
  },
  data() {
    return {
      modalIsOpen: false,
      activePage: 1,
      isActive: true,
    };
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    changePage: function(num) {
      this.activePage = num
    },
    nextPage: function(lastQuestion) {
      if(this.activePage < lastQuestion) this.activePage++
    },
    prevPage: function() {
      if(this.activePage > 1) this.activePage--
    },
    syncSpreadsheetData(jsonData) {
      this.$store.dispatch('userCbe/recordAnswer', {
        id: this.questionId,
        answers_attributes: [{
          content: {
            data: jsonData,
          },
        }],
      });
    },
  },
  watch: {
    activePage: function(newVal, oldVal) {
      eventBus.$emit("active-solution-index", newVal-1);
    },
  },
};
</script>