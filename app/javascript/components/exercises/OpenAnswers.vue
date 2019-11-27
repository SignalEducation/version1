<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="questionContent">Content</label>
        <div id="questionContent">
          <TextCorrection
            v-if="answerType === 'TextEditor'"
            :question-content="questionContent"
          />
          <SpreadsheetCorrection
            v-if="answerType === 'Spreadsheet' && spreadsheetData != null"
            :spreadsheet-data="spreadsheetData"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import TextCorrection from './TextCorrection.vue';
import SpreadsheetCorrection from './SpreadsheetCorrection.vue';

export default {
  components: {
    TextCorrection,
    SpreadsheetCorrection,
  },
  data() {
    return {
      questionContent: this.$parent.content,
      answerType: this.$parent.answerType,
      answerId: this.$parent.answerId,
      cbeId: this.$parent.cbeId,
      cbeUserLogId: this.$parent.cbeUserLogId,
      spreadsheetData: null,
    };
  },
  mounted() {
    this.getPrepopulatedAnswer();
  },
  methods: {
    getPrepopulatedAnswer() {
      if (this.answerType !== 'Spreadsheet') {
        return false;
      }

      axios
        .get(`/api/v1/cbes/${this.cbeId}/users_answer/${this.answerId}`)
        .then(response => {
          this.spreadsheetData = response.data;
        });

      return 'loaded';
    },
  },
};
</script>
