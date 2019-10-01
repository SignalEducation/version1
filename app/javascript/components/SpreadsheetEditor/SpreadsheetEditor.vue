<!-- eslint-disable -->

<template>
  <div class="container-fluid spreadsheetwrapper">
    <div class="well well-lg controls">
      <div class="btn-row top">
        <div class="btn-group">
          <DropDownSelect
            v-bind:buttonText="'Edit'"
            v-bind:dropdownOptions="[['Undo', 'g'], ['Redo', 'r'], ['Cut', 'f2'], ['Copy', 'n0'], ['Paste', 'n2']]"
            v-on:selected-value-updated="actionCalled"
          />
          <DropDownSelect
            v-bind:buttonText="'Format'"
            v-bind:dropdownOptions="[['Undo', 'g'], ['Redo', 'r'], ['Cut', 'f2'], ['Copy', 'n0'], ['Paste', 'n2']]"
            v-on:selected-value-updated="actionCalled"
          />
        </div>
      </div>

      <div class="btn-row">
        <div class="btn-group">
          <button
            type="button"
            v-bind:class="['btn btn-default reset']"
            @click="applyBoldStyle()" />
          <button
            type="button"
            v-bind:class="['btn btn-default undo']"
            @click="applyBoldStyle()" />
          <button
            type="button"
            v-bind:class="['btn btn-default redo']"
            @click="applyBoldStyle()" />
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
            v-on:selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'currency'"
            v-bind:dropdownOptions="currencyOptions"
            v-on:selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'percent'"
            v-bind:dropdownOptions="[['0%', 'p0'], ['0.00%', 'p2'], ['0.0%', 'p1']]"
            v-on:selected-value-updated="numberFormatChanged"
          />

          <DropDownSelect
            v-bind:iconClass="'fraction'"
            v-bind:dropdownOptions="[['# ?/?', '#/#'], ['# ??/??', '##/##']]"
            v-on:selected-value-updated="numberFormatChanged"
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
    </div>
    <wj-flex-sheet :initialized="initializeFlexSheet" :isTabHolderVisible="false">
      <wj-sheet :alternating-row-step="0"></wj-sheet>
    </wj-flex-sheet>

    <!-- Current sheet view -->
    <div id="tableHost"></div>
  </div>
</template>

<script>
/* eslint-disable */ 

  import * as wjcGrid from "@grapecity/wijmo.grid";
  import "@grapecity/wijmo.vue2.grid";
  import * as wjcCore from "@grapecity/wijmo";
  import '@grapecity/wijmo.vue2.input';
  import '@grapecity/wijmo.vue2.grid.sheet';
  import './SpreadsheetEditor.scss';
  import DropDownSelect from "../../lib/DropDownSelect";
  import getData from "./data";

  export default {
    components: {
      DropDownSelect,
    },
    data: function() {
      return {
        data: getData(),
        gridFilter: null,
        flexGrid: null,
        workbook: null,
        sheetIndex: -1,
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
      actionCalled: function () {
        console.log("action called");
      },
      numberFormatChanged: function (format) {
        this.flex.applyCellsStyle({ format: format });
      },
      initializeFlexSheet: function(flex) {
        flex.deferUpdate(() => {
          for (let sheetIdx = 0; sheetIdx < flex.sheets.length; sheetIdx++) {
            flex.selectedSheetIndex = sheetIdx;
            let sheetName = flex.selectedSheet.name;
            console.log(this.data);

            for (let rowIdx = 0; rowIdx < this.data.length; rowIdx++) {
              for (let colIdx = 0; colIdx < this.data[rowIdx].length; colIdx++) {
                flex.setCellData(rowIdx, colIdx, this.data[rowIdx][colIdx].value);
              }
            }
          }

          flex.selectedSheetIndex = 0;
          setTimeout(() => this._updateSelection(flex, flex.selection), 100);
        });

        flex.selectionChanged.addHandler((sender, args) => {
          this._updateSelection(flex, args.range);
        });

        // set the height of rows in the scrollable area
        flex.rows.defaultSize = 22;
        flex.rowHeaders.defaultSize = 100;
        flex.columns.defaultSize = 75;
        // set the height of rows in the column header area
        flex.columnHeaders.rows.defaultSize = 22;

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
      }
    }
  };
</script>
