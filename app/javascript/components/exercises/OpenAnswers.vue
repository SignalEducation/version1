<template>
  <div class="col-sm-12">
    <div class="form-group">
      <div id="questionContent">
        <TextCorrection
          v-if="answerType === 'TextEditor'"
          :question-content="questionContent"
          :editor-id="answerId"
        />
        <SpreadsheetCorrection
          v-if="answerType === 'Spreadsheet' && spreadsheetData != null"
          :spreadsheet-data="spreadsheetData"
        />
        <SpreadsheetCorrection
          v-if="answerType === 'ResponseSpreadsheet' && spreadsheetData != null"
          :spreadsheet-data="spreadsheetData"
        />
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
      let adress = ''

      if (this.answerType == 'Spreadsheet') {
        adress = `/api/v1/cbes/${this.cbeId}/users_answer/${this.answerId}`
      } else if (this.answerType == 'ResponseSpreadsheet') {
        adress = `/api/v1/cbes/${this.cbeId}/users_response/${this.answerId}`
      } else {
        return false;
      }

      axios
        .get(adress)
        .then(response => {
          this.spreadsheetData = response.data;
        });

      return 'loaded';
    },
  },
};
</script>
