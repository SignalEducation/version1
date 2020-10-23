<template>
  <div id="cbe-modals">
    <b-nav-text
      class="submit-btn-title"
      @click="submitPracticeQuestion(!modalIsOpen)"
    >
    </b-nav-text>

    <VueWindow
      v-show="modalIsOpen"
      :window-header="'Submit Btn'"
      :window-width="520"
      :window-height="370"
      :window-is-open="modalIsOpen"
      @updateWindowClose="handleChange"
    >
      <div slot="body"></div>
    </VueWindow>
  </div>
</template>

<script>
import axios from "axios";
import Calculator from "../Calculator.vue";
import VueWindow from "../VueWindow.vue";

export default {
  components: {
    Calculator,
    VueWindow,
  },
  data() {
    return {
      modalIsOpen: false,
    };
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
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    submitPracticeQuestion: function(modalValue) {
      this.modalIsOpen = modalValue;
      this.updateCurrentAnswer();
    },
    updateCurrentAnswer: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            practice_questions: this.questionContentArray,
            status: 'submited'
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
  },
};
</script>
