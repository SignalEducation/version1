<template>
  <div class="formula-row">
    <div class="cell-number">
      <span>{{ selectedCellReference }}</span>
    </div>
    <div class="formula-box">
      <input
        :value="selectedCellData"
        @focus="formulaBoxFocussed"
        @keyup="formulaUpdated"
      >
    </div>
  </div>
</template>

<script>
  import '../SpreadsheetEditor.scss';

  export default {
    props: {
      selectedCellRow: {
        type: Number,
        default: 0,
      },
      selectedCellCol: {
        type: Number,
        default: 0,
      },
      selectedCellReference: {
        type: String,
        default: '',
      },
      selectedCellData: {
        type: String,
        default: '',
      }
    },
    methods: {
      formulaBoxFocussed() {
        this.$emit('formula-box-focussed', this.selectedCellRow, this.selectedCellCol);
      },
      formulaUpdated(e) {
        this.$emit('formula-updated', this.selectedCellRow, this.selectedCellCol, e.target.value);
      },
    }
  };
</script>
