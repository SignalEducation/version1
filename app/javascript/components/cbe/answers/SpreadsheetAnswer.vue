<template>
  <section>
    <div class="answer">
      <SpreadsheetEditor
        :initial-data="answer"
        @spreadsheet-updated="syncSpreadsheetData"
      />
    </div>
  </section>
</template>

<script>
import EventBus from "../EventBus.vue";
import SpreadsheetEditor from '../../SpreadsheetEditor/SpreadsheetEditor.vue';

export default {
  components: {
    EventBus,
    SpreadsheetEditor,
  },
  props: {
    questionId: {
      type: Number,
      default: 0,
    },
    answerData: {
      type: Object,
      default: () => ({ content: { data: [] } }),
    },
  },
  data() {
    return {
      answer: this.getPrepopulatedAnswer(),
    };
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      let data = {
        id: this.questionId,
        score: 0,
        correct: null,
        cbe_question_id: this.questionId,
        answers_attributes: [{
          content: {
            data: jsonData,
          },
        }],
      }

      EventBus.$emit("update-question-answer", data);
      this.$store.dispatch('userCbe/recordAnswer', data);
    },
    getPrepopulatedAnswer() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[this.questionId];
      return initialValue ? initialValue.answers_attributes[0] : this.answerData;
    },
  },
};
</script>
