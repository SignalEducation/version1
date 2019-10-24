<template>
  <div class="btn-row top">
    <div class="btn-group">
      <DropDownSelect
        :button-text="'Edit'"
        :dropdown-options="[['Undo', 'undo'], ['Redo', 'redo'], ['Cut', 'cut'], ['Copy', 'copy'], ['Paste', 'paste'], ['Select All', 'select-all']]"
        @selected-value-updated="(action) => $emit('edit-action-called', action)"
      />
      <DropDownSelect
        :button-text="'Format'"
        :dropdown-options="[['Bold', 'bold'], ['Italic', 'italic'], ['Underline', 'underline']]"
        @selected-value-updated="(action) => $emit('format-action-called', action)"
      />
    </div>
  </div>
</template>

<script>
  import DropDownSelect from '../../../lib/DropDownSelect';
  import '../SpreadsheetEditor.scss';

  export default {
    components: {
      DropDownSelect,
    },
  }
</script>
