<template>
  <section>
    <div style="padding:15px;">
      <ul v-show="totalQuestions > 1" class="flex-container">
        <li v-if="totalQuestions > 1" @click="prevPage" class="lightgrey nav-ques-arrow"> &laquo; </li>
        <li v-else class="lightgrey nav-ques-arrow-shw"> &raquo; </li>
        <li class="flex-item">Question {{this.activePage}} of {{totalQuestions}}</li>
        <li v-if="this.activePage < totalQuestions && totalQuestions > 1" @click="nextPage(totalQuestions)" class="lightgrey nav-ques-arrow"> &raquo; </li>
        <li v-else class="lightgrey nav-ques-arrow-shw"> &raquo; </li>
        <div id="rightPaneTopUnderline" class="right-pane-underline"></div>
      </ul>

      <p v-if="totalQuestions > 1" v-html="questionContent.description"></p>
      <p v-else v-html="questionContent.description" class="practice-ques-single-question"></p>

      <div class="prac-ques-ans-box">
        <div v-if="questionContent.kind == 'open'">
          <TinyEditor
            :field-model.sync="questionContent.answer_content"
            :aditional-toolbar-options="[]"
            :editor-id="`${questionContent.id}`"
            :key="questionContent.id"
            @blur="$v.questionContent.$touch()"
          />
        </div>

        <div v-else>
          <spreadsheet-editor
            :initial-data="convertStr2Obj(questionContent.answer_content)"
            :key="questionContent.id"
            @spreadsheet-updated="syncSpreadsheetData"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<script>

function rightPaneScrolling() {
  let isScrolling;
  if ($("#pane_1").scrollTop() == 0) {
    setTimeout(() => {
      document.getElementById("rightPaneTopUnderline").style.display = "none";
    }, 500);
  }
  document.getElementById("rightPaneTopUnderline").style.display = "block";
  window.clearTimeout( isScrolling );
}

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
    stepLogId: {
      type: [String, Number],
    },
    practiceQuestionId: {
      type: [String, Number],
    },
  },
  data() {
    return {
      modalIsOpen: false,
      activePage: 1,
      isActive: true,
      questionContent: null,
      fillArr: null,
      lastTimeUpdated: new Date(),
    };
  },
  mounted() {
    document.querySelector('#pane_1').addEventListener("scroll", rightPaneScrolling);
    let questionChangeArr = new Array(this.totalQuestions);
    this.fillArr = questionChangeArr.fill(0);
    this.updateSubmitBtn(this.questionContentArray).then((response) => {
      if (response) {
        eventBus.$emit("active-solution-index", [this.fillArr.every(item => item === 1), this.activePage - 1]);
        eventBus.$emit("show-submit-btn", this.fillArr.every(item => item === 1));
      }
    });

    this.questionContentArray.forEach((question, index) => { if (question.current === true) this.activePage = index + 1; });
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
    convertStr2Obj(str) {
      if ((typeof str === 'object' && str !== null) || jQuery.isEmptyObject(str)) {
        return str;
      } else {
        return JSON.parse(str);
      }
    },
    nextPage: function(lastQuestion) {
      setTimeout(() => {
        document.getElementById("rightPaneTopUnderline").style.display = "none";
      }, 500);

      if (this.activePage < lastQuestion) this.activePage++;
    },
    prevPage: function() {
      setTimeout(() => {
        document.getElementById("rightPaneTopUnderline").style.display = "none";
      }, 500);

      if (this.activePage > 1) this.activePage--;
    },
    syncSpreadsheetData(jsonData) {
      this.questionContent.answer_content = { content: { data: jsonData } };
    },
    autoUpdateAnswer: function(newValue, oldValue = {}){
      const dateNow = new Date();
      // Update response data if last update is more then 10 seconds OR new value is bigger then 20 characters.
      if (dateNow - this.lastTimeUpdated > 10000 || (newValue.length - oldValue.length > 20)) {
        this.lastTimeUpdated = dateNow;
        this.updateCurrentAnswer();
      }
    },
    updateCurrentAnswer: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            practice_questions: this.questionContentArray,
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
    updateSubmitBtn: function(contentArr) {
      contentArr.forEach((pageArr, index) => {
        return new Promise((resolve) => {
          resolve(pageArr);
        }).then((data) => {
          let origDataLength = {};
          let userChangedDataLength = {};
          if (data.kind == 'spreadsheet') {
            if (data.content.content) { origDataLength =  Object.keys(data.content.content.data.data.dataTable).length; }
            if (data.answer_content.content) { origDataLength =  Object.keys(data.answer_content.content.data.data.dataTable).length; }
          } else {
            if (data.content) { origDataLength = data.content.length; }
            if (data.answer_content) { userChangedDataLength = data.answer_content.length; }
          }
          if (origDataLength != userChangedDataLength) {
            this.fillArr[index] = 1;
          }
        });
      });
      return new Promise((resolve) => {
        resolve(true);
      });
    },
  },
  watch: {
    activePage: function() {
      this.questionContent = this.questionContentArray[this.activePage - 1];
      this.questionContentArray.map(question => question.current = false);
      this.questionContent.current = true;
      this.updateCurrentAnswer();
    },
    "questionContent.answer_content": {
       handler(newValue, oldValue) {
        this.autoUpdateAnswer(newValue, oldValue);

        this.updateSubmitBtn(this.questionContentArray).then((response) => {
          if (response) {
            eventBus.$emit("active-solution-index", [this.fillArr.every(item => item === 1), this.activePage - 1]);
            eventBus.$emit("show-submit-btn", this.fillArr.every(item => item === 1));
          }
        });
       },
      deep: true
    }
  },
};
</script>
