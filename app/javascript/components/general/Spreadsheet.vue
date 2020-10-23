<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
          <input type='hidden' :name="hiddenFormName"   :id="hiddenFormId" :value="hiddenFormData"  />
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
      hiddenFormId: this.$parent.hidden_field_id,
      hiddenFormData: "",
      spreadsheetData: {},
    };
  },
  mounted() {
    try {
      this.spreadsheetData = JSON.parse(this.$parent.content);
    } catch (error) {
      console.log(error)
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
