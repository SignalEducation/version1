<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
          <input type='hidden' :name="hiddenFormName" :value="hiddenFormData"  />
          <SpreadsheetEditor :initial-data="spreadsheetData" @spreadsheet-updated="syncSpreadsheetData" />
      </div>
    </div>
  </div>
</template>

<script>
import SpreadsheetEditor from '../SpreadsheetEditor/SpreadsheetEditor.vue';

export default {
  components: {
    SpreadsheetEditor,
  },
  data() {
    return {
      hiddenFormName: this.$parent.hidden_field_name,
      hiddenFormData: "",
      spreadsheetData: {},
    };
  },
  mounted() {
    if (this.$parent.content) {
      this.spreadsheetData = JSON.parse(this.$parent.content);
    }
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      this.hiddenFormData = JSON.stringify({
        content: {
          data: jsonData
        },
      });

      this.spreadsheetData ={
        content: {
          data: jsonData
        },
      };
    },
  },
};
</script>
