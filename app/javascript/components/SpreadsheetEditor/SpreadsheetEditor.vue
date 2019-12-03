<!-- eslint-disable -->

<template>
  <div class="container-fluid spreadsheetwrapper">
    <div class="well well-lg controls">
      <FileBar
        @edit-action-called="editActionCalled"
        @format-action-called="formatActionCalled"
      />

      <CopyPasteBar
        :cut="cut"
        :copy="copy"
        :paste="paste"
        :canUndo="flex.undoStack && flex.undoStack.canUndo"
        :canRedo="flex.undoStack && flex.undoStack.canRedo"
        :undo="() => flex.undo()"
        :redo="() => flex.redo()"
        @reset-spreadsheet="resetSpreadsheet"
      />

      <FormatBar
        :applyBoldStyle="() => applyBoldStyle()"
        :applyItalicStyle="() => applyItalicStyle()"
        :applyUnderlineStyle="() => applyUnderlineStyle()"
        :fontSizeList="fontSizeList"
        :isBold="isBold"
        :isItalic="isItalic"
        :isUnderline="isUnderline"
        :fontSizeIdx="fontSizeIdx"
        :textAlign="textAlign"
        @apply-cell-text-align="applyCellTextAlign"
        @font-size-changed="fontSizeChanged"
        @number-format-changed="numberFormatChanged"
        @set-background-color="(color) => flex.applyCellsStyle({ backgroundColor: color })"
        @set-font-color="(color) => flex.applyCellsStyle({ color: color })"
      />

      <FormulaBar
        :selectedCellRow="selectedCellRow"
        :selectedCellCol="selectedCellCol"
        :selectedCellReference="selectedCell"
        :selectedCellData="selectedCellData"
        @formula-box-focussed="formulaBoxFocussed"
        @formula-updated="formulaUpdated"
      />
    </div>
    <wj-flex-sheet :initialized="initializeFlexSheet" :isTabHolderVisible="false">
      <wj-sheet :alternating-row-step="0"></wj-sheet>
    </wj-flex-sheet>
  </div>
</template>

<script>
/* eslint-disable */

  import * as wjcGrid from "@grapecity/wijmo.grid";
  import "@grapecity/wijmo.vue2.grid";
  import * as wjcCore from "@grapecity/wijmo";
  import '@grapecity/wijmo.vue2.input';
  import '@grapecity/wijmo.vue2.grid.sheet';
  import { UndoStack } from '@grapecity/wijmo.undo';
  import getData from "./data";

  import CopyPasteBar from './components/CopyPasteBar.vue';
  import FormatBar from './components/FormatBar.vue';
  import FormulaBar from './components/FormulaBar.vue';
  import FileBar from './components/FileBar.vue';

  import './SpreadsheetEditor.scss';

  export default {
    components: {
      CopyPasteBar,
      FileBar,
      FormatBar,
      FormulaBar,
    },
    props: {
      initialData: {
        type: Object,
        default: () => ({ kind: 'spreadsheet', content: { data: [] }}),
      },
    },
    computed: {
      spreadsheetData: function() {
        if (this.initialData.content && this.initialData.content.data && this.initialData.content.data.length > 0) {
          return this.initialData.content.data;
        } else {
          return getData();
        }
      },
    },
    data() {
      return {
        selectedCellRow: null,
        selectedCellCol: null,
        selectedCell: '',
        selectedCellData: '',
        copyString: '',
        format: '0',
        fontSizeIdx: 5,
        isBold: false,
        isItalic: false,
        isUnderline: false,
        textAlign: 'left',
        _updatingSelection: false,
        flex: {},
        fontSizeList: [
          { name: '8', value: '8px' },
          { name: '9', value: '9px' },
          { name: '10', value: '10px' },
          { name: '11', value: '11px' },
          { name: '12', value: '12px' },
          { name: '14', value: '14px' },
          { name: '16', value: '16px' },
          { name: '18', value: '18px' },
          { name: '20', value: '20px' },
          { name: '22', value: '22px' },
          { name: '24', value: '24px' }
        ],
      };
    },
    methods: {
      formulaBoxFocussed (row, col) {
        this.flex.startEditing(true, row, col, false);
      },
      formulaUpdated(row, col, value) {
        this.flex.cells.setCellData(row, col, value);
      },
      formatActionCalled (action) {
        switch (action) {
          case 'bold':
            this.applyBoldStyle();
            break;
          case 'italic':
            this.applyItalicStyle();
            break;
          case 'underline':
            this.applyUnderlineStyle();
          default:
            break;
        }
      },
      editActionCalled (action) {
        switch (action) {
          case 'undo':
            this.flex.undo();
            break;
          case 'redo':
            this.flex.redo();
            break;
          case 'cut':
            this.cut();
          case 'copy':
            this.copy();
            break;
          case 'paste':
            this.paste();
            break;
          case 'select-all':
            this.flex.select(1, 4000);
            break;
          default:
            break;
        }
      },
      cut() {
        this.copyString = this.flex.getClipString(this.flex.selection);
        wijmo.Clipboard.copy(this.copyString);
        this._clearCellData(this.flex.selection);
      },
      copy() {
        this.copyString = this.flex.getClipString(this.flex.selection);
        document.execCommand('copy');
        wijmo.Clipboard.copy(this.copyString);
      },
      paste() {
        if (this.copyString){
          this.flex.setClipString(this.copyString, this.flex.selection);
        }
      },
      numberFormatChanged (format) {
        this.flex.applyCellsStyle({ format: format });
      },
      initializeFlexSheet (flex) {
        this.flex = flex;
        this.flex.deferUpdate(() => {
          for (let sheetIdx = 0; sheetIdx < this.flex.sheets.length; sheetIdx++) {
            this.flex.selectedSheetIndex = sheetIdx;

            this._setInitialData(this.flex);
          }

          this.flex.selectedSheetIndex = 0;
          setTimeout(() => this._updateSelection(this.flex, this.flex.selection), 100);
        });
        this.flex.selectionChanged.addHandler((sender, args) => {
          this._updateSelection(this.flex, args.range);
        });
        this.flex.lostFocus.addHandler((sender, args) => {
          this.commitUpdatedData(this.flex);
        });
        this.flex.copied.addHandler((s,e)=>{
          this.copyString = s.getClipString();
        });
        this.flex.rows.defaultSize = 22;
        this.flex.rowHeaders.defaultSize = 100;
        this.flex.columns.defaultSize = 75;
        this.flex.columnHeaders.rows.defaultSize = 22;
        this.commitUpdatedData(this.flex);
      },
      fontSizeChanged(value) {
        if (!this._updatingSelection) {
          this.flex.applyCellsStyle({ fontSize: value });
        }
      },
      applyCellTextAlign(textAlign) {
        this.flex.applyCellsStyle({ textAlign: textAlign });
        this.textAlign = textAlign;
      },
      applyBoldStyle() {
        this.flex.applyCellsStyle({ fontWeight: this.isBold ? 'none' : 'bold' });
        this.isBold = !this.isBold;
      },
      applyUnderlineStyle() {
        this.flex.applyCellsStyle({ textDecoration: this.isUnderline ? 'none' : 'underline' });
        this.isUnderline = !this.isUnderline;
      },
      applyItalicStyle() {
        this.flex.applyCellsStyle({ fontStyle: this.isItalic ? 'none' : 'italic' });
        this.isItalic = !this.isItalic;
      },
      commitUpdatedData(flexSheet){
        const cellsJson = this._getJsonData(flexSheet);
        this.$emit('spreadsheet-updated', cellsJson);
      },
      resetSpreadsheet() {
        this._setInitialData(this.flex);
        this.$emit('spreadsheet-updated', this.spreadsheetData);
      },
      _updateSelection(flexSheet, sel) {
        let row = flexSheet.rows[sel.row],
            rCnt = flexSheet.rows.length,
            cCnt = flexSheet.columns.length,
            fontSizeIdx = 5;

        this._updatingSelection = true;

        if (sel.row > -1 && sel.col > -1 && rCnt > 0 && cCnt > 0 && sel.col < cCnt && sel.col2 < cCnt && sel.row < rCnt && sel.row2 < rCnt) {
          let cellContent = flexSheet.getCellData(sel.row, sel.col, false),
              cellStyle = flexSheet.selectedSheet.getCellStyle(sel.row, sel.col),
              cellFormat = null;

          if (cellStyle) {
            fontSizeIdx = this._checkFontSize(cellStyle.fontSize);
            cellFormat = cellStyle.format;
          }
          if (!!cellFormat) {
            this.format = cellFormat;
          } else {
            this.format = this._defaultCellFormat(cellContent);
          }
          const colName = flexSheet.columnHeaders.getCellData(0, sel.leftCol);
          const rowName = flexSheet.rowHeaders.getCellData(sel.topRow, 0);
          this.selectedCell = `${ colName }${ rowName }`;
          this.selectedCellRow = sel.topRow;
          this.selectedCellCol = sel.leftCol;
          this.selectedCellData = flexSheet.cells.getCellData(sel.topRow, sel.leftCol);

          this.fontSizeIdx = fontSizeIdx;

          let state = flexSheet.getSelectionFormatState();
          this.isBold = state.isBold;
          this.isItalic = state.isItalic;
          this.isUnderline = state.isUnderline;
          this.textAlign = state.textAlign;
        }

        this._updatingSelection = false;
      },
      _defaultCellFormat(cellContent) {
        if (wijmo.isInt(cellContent)) {
          return '0';
        } else if (wijmo.isNumber(cellContent)) {
          return 'n2';
        } else if (wijmo.isDate(cellContent)) {
          return 'd';
        } else { return '' }
      },
      _checkFontSize(fontSize) {
        let sizeList = this.fontSizeList;

        if (fontSize == null) {
          return 5;
        }

        for (let index = 0; index < sizeList.length; index++) {
          let size = sizeList[index];
          if (size.value === fontSize || size.name === fontSize) {
            return index;
          }
        }

        return 5;
      },
      _clearCellData(cellRange) {
        for (let colIdx = cellRange.leftCol; colIdx < (cellRange.leftCol + cellRange.columnSpan); colIdx += 1) {
          for (let rowIdx = cellRange.topRow; rowIdx < (cellRange.topRow + cellRange.rowSpan); rowIdx += 1) {
            this.flex.setCellData(rowIdx, colIdx, '');
          }
        }
      },
      _setInitialData (flex) {
        for (let cellIdx = 0; cellIdx < this.spreadsheetData.length; cellIdx += 1) {
          flex.setCellData(this.spreadsheetData[cellIdx].row, this.spreadsheetData[cellIdx].col, this.spreadsheetData[cellIdx].value);
          if (this.spreadsheetData[cellIdx]['format']) {
            flex.applyCellsStyle(
              { format: this.spreadsheetData[cellIdx]['format'] },
              [ new wjcGrid.CellRange(this.spreadsheetData[cellIdx].row, this.spreadsheetData[cellIdx].col) ]
            );
          }
          if (this.spreadsheetData[cellIdx]['fontSizeIdx']) {
            flex.applyCellsStyle(
              { fontSize: this.fontSizeList[this.spreadsheetData[cellIdx].fontSizeIdx].value },
              [ new wjcGrid.CellRange(this.spreadsheetData[cellIdx].row, this.spreadsheetData[cellIdx].col) ]
            );
          }
          if (this.spreadsheetData[cellIdx]['style']) {
            flex.applyCellsStyle(
              this.spreadsheetData[cellIdx]['style'],
              [ new wjcGrid.CellRange(this.spreadsheetData[cellIdx].row, this.spreadsheetData[cellIdx].col) ]
            );
          }
        }
      },
      _getJsonData(){
        const cells = this.flex.cells;
        const styledCells = this.flex.selectedSheet._styledCells;
        let cellsJson = [];
        let index = 0;
        for(let r = 0; r < cells.rows.length; r += 1){
          for(let c = 0; c < cells.columns.length; c += 1){
            let cell = {};
            cell['value'] = cells.getCellData(r,c);
            cell['row'] = r;
            cell['col'] = c;
            cell['colBinding'] = cells.columns[c].binding;
            const cellStyle = styledCells[index]
            if (cellStyle) {
              cell['style'] = cellStyle;
              cell['format'] = cellStyle.format;
              cell['fontSizeIdx'] = this._checkFontSize(cellStyle.fontSize);
            } else {
              cell['format'] = this._defaultCellFormat(cell['value']);
              cell['fontSizeIdx'] = 5;
            }

            [r * cells.columns.length + c + ''] ? this.flex.selectedSheet._styledCells[ r * cells.columns.length + c + ''] : null;
            cellsJson.push(cell);
            index += 1;
          }
        }
        return cellsJson;
      }
    }
  };
</script>
