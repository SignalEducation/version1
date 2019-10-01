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
import SpreadsheetEditor from '../../SpreadsheetEditor/SpreadsheetEditor.vue';

export default {
  components: {
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
      this.$store.dispatch('userCbe/recordAnswer', {
        id: this.questionId,
        answers: [{
          content: {
            data: jsonData,
          },
          cbe_question_id: this.questionId,
        }],
      });
    },
    getPrepopulatedAnswer() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[this.questionId];
      return initialValue ? initialValue.answers : this.answerData;
    },
  },
};
</script>
