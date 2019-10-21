<!-- eslint-disable -->

<template>
  <div class="container-fluid spreadsheetwrapper">
    <div class="well well-lg controls">
      <div class="btn-row top">
        <div class="btn-group">
          <DropDownSelect
            v-bind:buttonText="'Edit'"
            v-bind:dropdownOptions="[['Undo', 'undo'], ['Redo', 'redo'], ['Cut', 'cut'], ['Copy', 'copy'], ['Paste', 'paste'], ['Select All', 'select-all']]"
            @selected-value-updated="editActionCalled"
          />
          <DropDownSelect
            v-bind:buttonText="'Format'"
            v-bind:dropdownOptions="[['Bold', 'bold'], ['Italic', 'italic'], ['Underline', 'underline']]"
            @selected-value-updated="formatActionCalled"
          />
        </div>
      </div>

      <div class="btn-row">
        <div class="btn-group">
          <button
            type="button"
            :class="'btn btn-default reset'"
            @click="showResetModal"
          />
          <div ref="reset-spreadsheet" class="modal" v-show="resetModalIsOpen">
            <div class="modal-content">
              <div class="modal-header bg-cbe-gray">
                <span class="title">
                  Reset Spreadsheet
                </span>

                <span
                  class="close"
                  @click="resetModalIsOpen = !resetModalIsOpen"
                >
                  &times;
                </span>
              </div>

              <div class="modal-internal-content">
                <div class="d-block">
                  <p>
                    Resetting the spreadsheet will revert any changes you have made so far.
                    Are you sure you want to reset the spreadsheet?
                  </p>
                  <b-button
                    variant="outline-success"
                    @click="resetModalIsOpen = !resetModalIsOpen"
                  >
                    Cancel
                  </b-button>
                  <b-button
                    variant="outline-danger"
                    @click="resetSpreadsheet"
                  >
                    Reset Sheet
                  </b-button>
                </div>
              </div>
            </div>
          </div>
          <button
            type="button"
            v-bind:class="['btn btn-default cut']"
            @click="cut()" />
          <button
            type="button"
            v-bind:class="['btn btn-default copy']"
            @click="copy()" />
          <button
            type="button"
            v-bind:class="['btn btn-default paste']"
            @click="paste()" />
          <button
            type="button"
            v-bind:class="['btn btn-default undo']"
            :disabled="flex.undoStack && !flex.undoStack.canUndo"
            @click="flex.undo()" />
          <button
            type="button"
            v-bind:class="['btn btn-default redo']"
            :disabled="flex.undoStack && !flex.undoStack.canRedo"
            @click="flex.redo()" />
        </div>
      </div>
      <div class="btn-row">
        <wj-combo-box
          style="width:80px"
          :itemsSource="fontSizeList"
          :selectedIndex="fontSizeIdx"
          displayMemberPath="name"
          selectedValuePath="value"
          :isEditable="false"
          :selectedIndexChanged="fontSizeChanged">
        </wj-combo-box>
        <div class="btn-group">
          <button
            type="button"
            v-bind:class="['btn btn-default bold', { active: isBold }]"
            @click="applyBoldStyle()" />
          <button
            type="button"
            v-bind:class="['btn btn-default italic', { active: isItalic }]"
            @click="applyItalicStyle()" />
          <button
            type="button"
            v-bind:class="['btn btn-default underline', { active: isUnderline }]"
            @click="applyUnderlineStyle()" />
          <button
            type="button"
            class="btn btn-default fontcolor"
            @click="showColorPicker($event, false)" />
          <button
            type="button"
            class="btn btn-default fillcolor"
            @click="showColorPicker($event, true)" />
          <wj-color-picker
            style="display:none;position:fixed;z-index:100"
            :initialized="colorPickerInit">
          </wj-color-picker>
          <button
            type="button"
            v-bind:class="['btn btn-default left-align', { active: textAlign == 'left' }]"
            @click="applyCellTextAlign('left')" />
          <button
            type="button"
            v-bind:class="['btn btn-default center-align', { active: textAlign == 'center' }]"
            @click="applyCellTextAlign('center')" />
          <button
            type="button"
            v-bind:class="['btn btn-default right-align', { active: textAlign == 'right' }]"
            @click="applyCellTextAlign('right')" />

          <DropDownSelect
            v-bind:iconClass="'number-format'"
            v-bind:dropdownOptions="[['General', 'g'], ['Custom', 'r'], ['#0.00', 'f2'], ['#,##0', 'n0'], ['#,##0.00', 'n2']]"
            @selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'currency'"
            v-bind:dropdownOptions="currencyOptions"
            @selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'percent'"
            v-bind:dropdownOptions="[['0%', 'p0'], ['0.00%', 'p2'], ['0.0%', 'p1']]"
            @selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'fraction'"
            v-bind:dropdownOptions="[['# ?/?', '#/#'], ['# ??/??', '##/##']]"
            @selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'datetime'"
            v-bind:dropdownOptions="[
              ['M/d/yyyy', 'M/d/yyyy'], ['d-MMM-yy', 'd-MMM-yy'], ['d-MMM', 'd-MMM'],
              ['MMM-yy', 'MMM-yy'], ['h:mm AM/PM', 'h:mm tt'], ['h:mm:ss AM/PM', 'h:mm:ss tt'],
              ['h:mm', 'h:mm'], ['h:mm:ss', 'h:mm:ss'], ['M/d/yyyy h:mm', 'M/d/yyyy h:mm'],
              ['mm:ss', 'mm:ss']
            ]"
            v-on:selected-value-updated="numberFormatChanged"
          />
        </div>
      </div>
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
  import './SpreadsheetEditor.scss';
  import DropDownSelect from "../../lib/DropDownSelect";
  import FormulaBar from './components/FormulaBar.vue';
  import getData from "./data";

  export default {
    components: {
      DropDownSelect,
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
        undoStack:  null,
        resetModalIsOpen: false,
        currencyOptions: [
          ['General', 'c'], ['Custom', 'r'], ["$#,##0", "\$#,##0"], ['$#,##0.00', "\$#,##0.00"]
        ],
        fonts: [
          { name: 'Arial', value: 'Arial, Helvetica, sans-serif' },
          { name: 'Arial Black', value: '"Arial Black", Gadget, sans-serif' },
          { name: 'Comic Sans MS', value: '"Comic Sans MS", cursive, sans-serif' },
          { name: 'Courier New', value: '"Courier New", Courier, monospace' },
          { name: 'Georgia', value: 'Georgia, serif' },
          { name: 'Impact', value: 'Impact, Charcoal, sans-serif' },
          { name: 'Lucida Console', value: '"Lucida Console", Monaco, monospace' },
          { name: 'Lucida Sans Unicode', value: '"Lucida Sans Unicode", "Lucida Grande", sans-serif' },
          { name: 'Palatino Linotype', value: '"Palatino Linotype", "Book Antiqua", Palatino, serif' },
          { name: 'Tahoma', value: 'Tahoma, Geneva, sans-serif' },
          { name: 'Segoe UI', value: '"Segoe UI", "Roboto", sans-serif' },
          { name: 'Times New Roman', value: '"Times New Roman", Times, serif' },
          { name: 'Trebuchet MS', value: '"Trebuchet MS", Helvetica, sans-serif' },
          { name: 'Verdana', value: 'Verdana, Geneva, sans-serif' }
        ],
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
        format: '0',
        fontIdx: 0,
        fontSizeIdx: 5,
        isBold: false,
        isItalic: false,
        isUnderline: false,
        textAlign: 'left',
        _updatingSelection: false,
        _applyFillColor: false,
        flex: {},
        colorPicker: {},
      };
    },
    methods: {
      formulaBoxFocussed (row, col) {
        this.flex.startEditing(true, row, col, false);
      },
      formulaUpdated(row, col, value) {
        this.flex.cells.setCellData(row, col, value);
      },
      showResetModal () {
        this.resetModalIsOpen = true;
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
        flex.deferUpdate(() => {
          for (let sheetIdx = 0; sheetIdx < flex.sheets.length; sheetIdx++) {
            flex.selectedSheetIndex = sheetIdx;

            this._setInitialData(flex);
          }

          flex.selectedSheetIndex = 0;
          setTimeout(() => this._updateSelection(flex, flex.selection), 100);
        });
        flex.selectionChanged.addHandler((sender, args) => {
          this._updateSelection(flex, args.range);
        });
        flex.lostFocus.addHandler((sender, args) => {
          this.commitUpdatedData(flex);
        });
        flex.copied.addHandler((s,e)=>{
          this.copyString = s.getClipString();
        });
        flex.rows.defaultSize = 22;
        flex.rowHeaders.defaultSize = 100;
        flex.columns.defaultSize = 75;
        flex.columnHeaders.rows.defaultSize = 22;
        this.commitUpdatedData(flex);

        this.flex = flex;
      },
      fontChanged(sender) {
        if (sender.selectedItem && !this._updatingSelection) {
          this.flex.applyCellsStyle({ fontFamily: sender.selectedItem.value });
        }
      },
      fontSizeChanged(sender) {
        if (sender.selectedItem && !this._updatingSelection) {
          this.flex.applyCellsStyle({ fontSize: sender.selectedItem.value });
        }
      },
      colorPickerInit(colorPicker) {
        let blurEvt = /firefox/i.test(window.navigator.userAgent) ? 'blur' : 'focusout';
        colorPicker.hostElement.addEventListener(blurEvt, () => {
          setTimeout(() => {
            if (!colorPicker.containsFocus()) {
              this._applyFillColor = false;
              colorPicker.hostElement.style.display = 'none';
            }
          }, 0);
        });
        colorPicker.valueChanged.addHandler(() => {
          if (this._applyFillColor) {
            this.flex.applyCellsStyle({ backgroundColor: colorPicker.value });
          } else {
            this.flex.applyCellsStyle({ color: colorPicker.value });
          }
        });

        this.colorPicker = colorPicker;
      },
      formatChanged(sender) {
        if (sender.selectedIndex >= 0) {
          this.flex.applyCellsStyle({ format: sender.selectedValue });
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
      showColorPicker(e, isFillColor) {
        let offset = this._cumulativeOffset(e.target),
            he = this.colorPicker.hostElement;

        he.style.display = 'inline';
        he.style.left = offset.left + 'px';
        he.style.top = offset.top - he.clientHeight - 5 + 'px';
        he.focus();

        this._applyFillColor = isFillColor;
      },
      commitUpdatedData(flexSheet){
        const cellsJson = this._getJsonData(flexSheet);
        this.$emit('spreadsheet-updated', cellsJson);
      },
      resetSpreadsheet() {
        this._setInitialData(this.flex);
        this.$emit('spreadsheet-updated', this.spreadsheetData);
        this.resetModalIsOpen = false;
      },
      _updateSelection(flexSheet, sel) {
        let row = flexSheet.rows[sel.row],
            rCnt = flexSheet.rows.length,
            cCnt = flexSheet.columns.length,
            fontIdx = 0,
            fontSizeIdx = 5;

        this._updatingSelection = true;

        if (sel.row > -1 && sel.col > -1 && rCnt > 0 && cCnt > 0 && sel.col < cCnt && sel.col2 < cCnt && sel.row < rCnt && sel.row2 < rCnt) {
          let cellContent = flexSheet.getCellData(sel.row, sel.col, false),
              cellStyle = flexSheet.selectedSheet.getCellStyle(sel.row, sel.col),
              cellFormat = null;

          if (cellStyle) {
            fontIdx = this._checkFontfamily(cellStyle.fontFamily);
            fontSizeIdx = this._checkFontSize(cellStyle.fontSize);
            cellFormat = cellStyle.format;
          }

          let format;
          if (!!cellFormat) {
            format = cellFormat;
          } else {
            if (wijmo.isInt(cellContent)) {
              format = '0';
            } else if (wijmo.isNumber(cellContent)) {
              format = 'n2';
            } else if (wijmo.isDate(cellContent)) {
              format = 'd';
            }
          }
          const colName = flexSheet.columnHeaders.getCellData(0, sel.leftCol);
          const rowName = flexSheet.rowHeaders.getCellData(sel.topRow, 0);
          this.selectedCell = `${ colName }${ rowName }`;
          this.selectedCellRow = sel.topRow;
          this.selectedCellCol = sel.leftCol;
          this.selectedCellData = flexSheet.cells.getCellData(sel.topRow, sel.leftCol);

          this.fontIdx = fontIdx;
          this.fontSizeIdx = fontSizeIdx;
          
          let state = flexSheet.getSelectionFormatState();
          this.isBold = state.isBold;
          this.isItalic = state.isItalic;
          this.isUnderline = state.isUnderline;
          this.textAlign = state.textAlign;
        }

        this._updatingSelection = false;
      },
      _checkFontfamily(fontFamily) {
        let fonts = this.fonts;

        if (!fontFamily) {
          return 0;
        }

        for (let fontIndex = 0; fontIndex < fonts.length; fontIndex++) {
          let font = fonts[fontIndex];
          if (font.name === fontFamily || font.value === fontFamily) {
            return fontIndex;
          }
        }

        return 0;
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
      _cumulativeOffset(element) {
        let top = 0,
            left = 0,
            scrollTop = 0,
            scrollLeft = 0;

        do {
          top += element.offsetTop || 0;
          left += element.offsetLeft || 0;
          scrollTop += element.scrollTop || 0;
          scrollLeft += element.scrollLeft || 0;
          element = element.offsetParent;
        } while (element && !(element instanceof HTMLBodyElement));

        scrollTop += document.body.scrollTop || document.documentElement.scrollTop;
        scrollLeft += document.body.scrollLeft || document.documentElement.scrollLeft;

        return {
          top: top - scrollTop,
          left: left - scrollLeft
        };
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
        }
      },
      _getJsonData(flexSheet){
        const cells = flexSheet.cells;
        let cellsJson = [];
        for(let r = 0; r < cells.rows.length; r += 1){
          for(let c = 0; c < cells.columns.length; c += 1){
            let cell = {};
            cell['value'] = cells.getCellData(r,c);
            cell['row'] = r;
            cell['col'] = c;
            cell['colBinding'] = cells.columns[c].binding;
            cell['style'] = flexSheet.selectedSheet._styledCells
            [r * cells.columns.length + c + ''] ? flexSheet.selectedSheet._styledCells[ r * cells.columns.length + c + ''] : null;
            cellsJson.push(cell);
          }
        }
        return cellsJson;
      }
    }
  };
</script>
