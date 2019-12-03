<template>
  <section class="answers">
    <div class="answers">
      <SpreadsheetEditor
        :initialData="answersArray.slice(-1).pop()"
        v-on:spreadsheet-updated="syncSpreadsheetData"
      />
    </div>
  </section>
</template>

<script>
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';
import SpreadsheetEditor from '../../../SpreadsheetEditor/SpreadsheetEditor.vue';

export default {
  components: {
    SpreadsheetEditor,
  },
  mixins: [validationMixin],
  props: {
    answersArray: {
      type: Array,
      default: () => [],
    },
    questionId: {
      type: Number,
      default: 0,
    },
  },
  data() {
    return {
      id: 0,
      answer: '',
    };
  },
  validations: {
    answer: {
      required,
    },
  },
  methods: {
    syncSpreadsheetData(jsonData, sheetData) {
      this.answersArray[0] = {
        kind: 'spreadsheet',
        content: {
          data: jsonData,
          sheetData
        },
      };
    },
  },
};
</script>
