<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="questionContent">Content</label>
        <div id="questionContent">
          <SpreadsheetEditor
            :initial-data="spreadsheetData"
          />
        </div>
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
  props: {
    spreadsheetData: {
      type: Object,
      default: () => ({ content: { data: [] } }),
    },
  },
};
</script>
