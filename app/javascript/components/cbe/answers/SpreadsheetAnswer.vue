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
      lastTimeUpdated: new Date(),
    };
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      const dateNow = new Date();
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

      this.$store.dispatch('userCbe/recordAnswer', data);

      // Update answers data if last update is more then 10 seconds.
      if (dateNow - this.lastTimeUpdated > 10000) {
        this.lastTimeUpdated = dateNow;
        EventBus.$emit("update-question-answer", data);
      }

    },
    getPrepopulatedAnswer() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[this.questionId];
      return initialValue ? initialValue.answers_attributes[0] : this.answerData;
    },
  },
};
</script>
