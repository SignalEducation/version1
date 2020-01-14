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
        :canUndo="flex.parent && flex.parent.undoManager() && flex.parent.undoManager().canUndo()"
        :canRedo="flex.parent && flex.parent.undoManager() && flex.parent.undoManager().canRedo()"
        :undo="() => flex.parent.undoManager().undo()"
        :redo="() => flex.parent.undoManager().redo()"
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
        @set-background-color="setBackColor"
        @set-font-color="setFontColor"
      />
      <div class="formula-row">
        <div class="cell-number">{{ selectedCell }}</div>
        <div class="formula-box">
          <div
            ref="fbxRef"
            contenteditable="true"
            spellcheck="false"
            style="font-family: Calibri;height:100%;width:100%;padding: 4px;"
          ></div>
        </div>
      </div>
    </div>
    <gc-spread-sheets
        :hostClass='hostClass'
        :enableFormulaTextbox='true'
        @cellChanged='commitUpdatedData'
        @selectionChanged='updateSelection'
        @workbookInitialized='initializeFlexSheet'
        v-observe-visibility="sheetIsVisible"
      >
        <gc-worksheet
          :autoGenerateColumns='autoGenerateColumns'
        />
      </gc-spread-sheets>
  </div>
</template>

<script>
  /* eslint-disable */
  import Vue from 'vue';
  import VueObserveVisibility from 'vue-observe-visibility';
  Vue.use(VueObserveVisibility);

  const licenseKey = () => {
    if (location.hostname === 'www.learnsignal.com') {
      return "Learnsignal,www.learnsignal.com,298494625431851#B0uxsOzlUaSR4RRVnYwsWdJB5L6M5b5gkc8FjNalDZmFDSIpVZoNHatFFMqFVQi94aYl6SvB7UYRFN4NFTaFTQtRTazdTN6lHbsZ5QhNFSmF7N9k4cBJTa5MXcwcnUmVDRxR7ZkdTWLNVRrEUUYNmTsZUYoljQyRWbvt6dDVlWBh5NuZTUSFWcmNnY4UlTRdEeadnRth7L9JzZvRzcRNGZ8VTayk6N8h4ZFVFcRxGewl5Yx2kNJVzNPNkZYN6MJplbV34U7MnZXNFb59kYmxWahBjboFkRrhnN7QHeyonYVxmQMxGRrkmZ6k6Yux6aiojITJCLiIkNzQTOGRjMiojIIJCLwMjNycDNzITN0IicfJye#4Xfd5nIV34M6IiOiMkIsIyMx8idgMlSgQWYlJHcTJiOi8kI1tlOiQmcQJCLicDM4UTMwAiMxITM9EDMyIiOiQncDJCLi46bj9Cbh96ZpNnbyFWZs9yd7dnI0IyctRkIsICbh96ZpNnbyFWZMJiOiEmTDJCLiETN8EzM4UjM6QTO4gTOyIiOiQWSiwSflNHbhZmOiI7ckJye0ICbuFkI1pjIEJCLi4TPBJlU5FWQmR4YWNjc4IzLWtmTOFVQXFHcxZUT4oVdw5ETPdHc4E7Lyp4RLZkUnd5bBVza6o7bi94ZllWcnZ6U9V7VTJFeI9GNOF6M5kjcjhGOwAzYBxkQwNHVTplRVdTbQJ7T7QDWKZgU";
    } else {
      return "Learnsignal,learnsignal.com,937219162519253#B0HMvUYEpVcylkUrFVaxVzKxFVV44GRNZlRaZlaoJXc8okUZJ7MUNVV7MHRtFkVOtUeFNFNSR5bBpWWZNmNzkXTwN5c4oXOGNWTPdnc6InRs3CUMVGc7RkZF5GUwkUdo3CZkFkTSFFaG3WYvgUQih6S5sESI9mboVTOaRmdkBza6IFRJ5UTzRWOIZGUydlbWZWMihXet9WeyITOVBXUFZXbzgjYBF4M5EWevkHVFVVbS5mTw3EOHlmRqtCe5UHMThmMYZVawgjZIVndLlla4RFTw4UOttGcrR6MOZnT9ETaK3CWKNlSRV5Z4FXViojITJCLiATQxADO8UUNiojIIJCL7UzN8ATN4UjM0IicfJye&Qf35VfiU5TzYjI0IyQiwiIzEjL6ByUKBCZhVmcwNlI0IiTis7W0ICZyBlIsIiM5IDNxADIyEjMxkTMwIjI0ICdyNkIsISbvNmLsFmbnl6cuJXYlxmI0IyctRkIsICbh96ZpNnbyFWZMJiOiEmTDJCLiMTNykTM5IjNxkTMyczM9IiOiQWSiwSflNHbhZmOiI7ckJye0ICbuFkI1pjIEJCLi4TPRNmZjtmUER4NXVHaB94LoFGa5hUcLdFeotWT8pmb7tGMpdlMVV6LVF6ZBlnUUxWeGV4T8EWeYJkekFjaNNFMndTUmNjY9JXZ8k7MVdFS5IFeX34KsN4KSd6YKNkVppEUuZDZPZVVyRVTxDi";
    }
  }

  import '@grapecity/spread-sheets/styles/gc.spread.sheets.excel2016colorful.css';
  import '@grapecity/spread-sheets-vue';

  import GC from "@grapecity/spread-sheets";

  import CopyPasteBar from './components/CopyPasteBar.vue';
  import FormatBar from './components/FormatBar.vue';
  import FileBar from './components/FileBar.vue';

  import './SpreadsheetEditor.scss';

  GC.Spread.Sheets.LicenseKey = licenseKey();

  export default {
    components: {
      CopyPasteBar,
      FileBar,
      FormatBar,
    },
    props: {
      initialData: {
        type: Object,
        default: () => ({ kind: 'spreadsheet', content: { data: {} }}),
      },
    },
    computed: {
      spreadsheetData: function() {
        if (this.initialData.content && this.initialData.content.data && this.initialData.content.data.data) {
          return this.initialData.content.data;
        } else {
          return null;
        }
      }
    },
    data() {
      return {
        hostClass:'spread-host',
        autoGenerateColumns:true,
        width:300,
        visible:true,
        resizable:true,
        selectedCellRow: null,
        selectedCellCol: null,
        selectedCell: '',
        selectedCellData: '',
        copyString: '',
        format: '0',
        fontSizeIdx: '12',
        isBold: false,
        isItalic: false,
        isUnderline: false,
        textAlign: 'left',
        flex: {},
        fbx: {},
        fontSizeList: ['8','9','10','11','12','14','16','18','20','22','24'],
      };
    },
    methods: {
      formulaBoxFocussed (row, col) {
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
            this.flex.parent.undoManager().undo();
            break;
          case 'redo':
            this.flex.parent.undoManager().redo();
            break;
          case 'cut':
            this.cut();
          case 'copy':
            this.copy();
            break;
          case 'paste':
            this.paste();
            break;
          default:
            break;
        }
      },
      cut() {
        this.flex.parent.commandManager().execute({ cmd: 'cut',  sheetName: this.flex.name()});
      },
      copy() {
        this.flex.parent.commandManager().execute({ cmd: 'copy',  sheetName: this.flex.name()});
      },
      paste() {
        this.flex.parent.commandManager().execute({ cmd: 'paste',  sheetName: this.flex.name()});
      },
      numberFormatChanged (format) {
        let sel = this.flex.getSelections()[0];
        for (let row = sel.row; row < (sel.row + sel.rowCount); row += 1) {
          for (let col = sel.col; col < (sel.col + sel.colCount); col += 1) {
            this.flex.getCell(sel.row, sel.col).formatter(format);
          }
        }
      },
      initializeFlexSheet (spread) {
        const fbx = new GC.Spread.Sheets.FormulaTextBox.FormulaTextBox(this.$refs.fbxRef);
        fbx.workbook(spread);
        this.flex = spread.getSheet(0);
        if (this.spreadsheetData) {
          spread.suspendPaint();
          this.flex.setDataSource(this.flex.fromJSON(JSON.parse(JSON.stringify(this.spreadsheetData))));
          spread.resumePaint();
        }
        for (var i = 0; i < this.flex.getRowCount(); i++) {
          this.flex.autoFitRow(i);
        }
        for (var i = 0; i < this.flex.getColumnCount(); i++) {
          this.flex.autoFitColumn(i);
        }
      },
      fontSizeChanged(value) {
        let sel = this.flex.getSelections()[0];
        let range = this.flex.getRange(sel.row, sel.col, sel.rowCount, sel.colCount);
        range.font(`${ value }px ${ this.isBold ? 'bold' : '' } ${ this.isItalic ? 'italic' : '' } Calibri`);
      },
      applyCellTextAlign(textAlign) {
        const align = {
          'left': GC.Spread.Sheets.HorizontalAlign.left,
          'center': GC.Spread.Sheets.HorizontalAlign.center,
          'right': GC.Spread.Sheets.HorizontalAlign.right,
        }
        let sel = this.flex.getSelections()[0];
        let range = this.flex.getRange(sel.row, sel.col, sel.rowCount, sel.colCount);
        range.hAlign(align[textAlign]);
        this.textAlign = textAlign;
      },
      _applyFontStyle(isStyle, style) {
        const sel = this.flex.getSelections()[0];
        for (let row = sel.row; row < sel.row + sel.rowCount; row += 1) {
          for (let col = sel.col; col < sel.col + sel.colCount; col += 1) {
            let cell = this.flex.getCell(row, col)
            let font = cell.font();
            cell.font(`${isStyle ? '' : style} ${ font.replace(style, '') }`)
          }
        }
      },
      applyBoldStyle() {
        this._applyFontStyle(this.isBold, 'bold');
        this.isBold = !this.isBold;
      },
      applyUnderlineStyle() {
        let sel = this.flex.getSelections()[0];
        for (let row = sel.row; row < (sel.row + sel.rowCount); row += 1) {
          for (let col = sel.col; col < (sel.col + sel.colCount); col += 1) {
            this.flex.getCell(sel.row, sel.col).textDecoration(GC.Spread.Sheets.TextDecorationType.underline);
          }
        }
        this.isUnderline = !this.isUnderline;
      },
      applyItalicStyle() {
        this._applyFontStyle(this.isItalic, 'italic');
        this.isItalic = !this.isItalic;
      },
      commitUpdatedData(event, info){
        this.$emit('spreadsheet-updated', info.sheet.toJSON());
      },
      resetSpreadsheet() {
        this._setInitialData(this.flex);
        this.$emit('spreadsheet-updated', this.flex.toJSON());
      },
      sheetIsVisible(isVisible, entry) {
        if(isVisible) {
          this.flex.parent.refresh();
        }
      },
      setBackColor(color) {
        let sel = this.flex.getSelections()[0];
        let range = this.flex.getRange(sel.row, sel.col, sel.rowCount, sel.colCount);
        range.backColor(color);
      },
      setFontColor(color) {
        let sel = this.flex.getSelections()[0];
        let range = this.flex.getRange(sel.row, sel.col, sel.rowCount, sel.colCount);
        range.foreColor(color);
      },
      updateSelection(event, sel) {
        const selection = sel.newSelections[0];
        const sheet = sel.sheet;
        const {rowCount, colCount, row, col} = selection;
        const fontSizeIdx = '12';
        const cell = sheet.getCell(row, col);

        if (row > -1 && col > -1 && rowCount > 0 && colCount > 0) {
          let cellContent = cell.value(),
              cellStyle = sheet.getStyle(row, col),
              cellFormat = cell.formatter();

          this.format = cell.formatter();
          const colName = this.flex.getCell(row, col, GC.Spread.Sheets.SheetArea.colHeader).value();
          const rowName = this.flex.getCell(row, col, GC.Spread.Sheets.SheetArea.rowHeader).value();
          this.selectedCell = GC.Spread.Sheets.CalcEngine.rangeToFormula(selection);
          this.selectedCellData = cellContent;
          this.fontSizeIdx = this._checkFontSize(cell.font());
          this.isBold = cell.font().includes('bold');
          this.isItalic = cell.font().includes('italic');
          this.isUnderline = cellStyle && cellStyle.textDecoration && cellStyle.textDecoration === 1;
          switch (cell.hAlign()) {
            case 0:
              this.textAlign = 'left';
              break;
            case 1:
              this.textAlign = 'center';
            case 2:
              this.textAlign = 'right';
              break;
            default:
              this.textAlign = 'right';
              break;
          }
        }
      },
      _checkFontSize(fontSize) {
        const sizeList = this.fontSizeList;

        if (fontSize == null) {
          return '12';
        }

        const estimatedSize = Math.round((Number(fontSize.match(/\d*\.?\d*/)[0])));
        return sizeList.reduce((prev, curr) => {
          return Math.abs(Number(curr) - estimatedSize) < Math.abs(Number(prev) - estimatedSize) ? curr : prev
        });
      },
      _clearCellData(cellRange) {
        for (let colIdx = cellRange.leftCol; colIdx < (cellRange.leftCol + cellRange.columnSpan); colIdx += 1) {
          for (let rowIdx = cellRange.topRow; rowIdx < (cellRange.topRow + cellRange.rowSpan); rowIdx += 1) {
            this.flex.setCellData(rowIdx, colIdx, '');
          }
        }
      },
    }
  };
</script>
