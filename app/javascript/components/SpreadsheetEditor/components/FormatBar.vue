<template>
  <div class="btn-row">
    <wj-combo-box
      style="width:80px"
      :items-source="fontSizeList"
      :selected-index="fontSizeIdx"
      display-member-path="name"
      selected-value-path="value"
      :is-editable="false"
      :selected-index-changed="fontSizeChanged"
    />
    <div class="btn-group">
      <button
        type="button"
        :class="['btn btn-default bold', { active: isBold }]"
        @click="applyBoldStyle"
      />
      <button
        type="button"
        :class="['btn btn-default italic', { active: isItalic }]"
        @click="applyItalicStyle"
      />
      <button
        type="button"
        :class="['btn btn-default underline', { active: isUnderline }]"
        @click="applyUnderlineStyle"
      />
      <button
        type="button"
        class="btn btn-default fontcolor"
        @click="showColorPicker($event, false)"
      />
      <button
        type="button"
        class="btn btn-default fillcolor"
        @click="showColorPicker($event, true)"
      />
      <wj-color-picker
        style="display:none;z-index:100"
        :initialized="colorPickerInit"
      />
      <button
        type="button"
        :class="['btn btn-default left-align', { active: textAlign == 'left' }]"
        @click="$emit('apply-cell-text-align', 'left')"
      />
      <button
        type="button"
        :class="['btn btn-default center-align', { active: textAlign == 'center' }]"
        @click="$emit('apply-cell-text-align', 'center')"
      />
      <button
        type="button"
        :class="['btn btn-default right-align', { active: textAlign == 'right' }]"
        @click="$emit('apply-cell-text-align', 'right')"
      />

      <DropDownSelect
        :icon-class="'number-format'"
        :dropdown-options="[['General', 'g'], ['Custom', 'r'], ['#0.00', 'f2'], ['#,##0', 'n0'], ['#,##0.00', 'n2']]"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'currency'"
        :dropdown-options="currencyOptions"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'percent'"
        :dropdown-options="[['0%', 'p0'], ['0.00%', 'p2'], ['0.0%', 'p1']]"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'fraction'"
        :dropdown-options="[['# ?/?', '#/#'], ['# ??/??', '##/##']]"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'datetime'"
        :dropdown-options="[
          ['M/d/yyyy', 'M/d/yyyy'], ['d-MMM-yy', 'd-MMM-yy'], ['d-MMM', 'd-MMM'],
          ['MMM-yy', 'MMM-yy'], ['h:mm AM/PM', 'h:mm tt'], ['h:mm:ss AM/PM', 'h:mm:ss tt'],
          ['h:mm', 'h:mm'], ['h:mm:ss', 'h:mm:ss'], ['M/d/yyyy h:mm', 'M/d/yyyy h:mm'],
          ['mm:ss', 'mm:ss']
        ]"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />
    </div>
  </div>
</template>

<script>
// eslint-disable-next-line import/no-extraneous-dependencies

import '@grapecity/wijmo.vue2.core';
import '@grapecity/wijmo.vue2.input';
// eslint-disable-next-line import/no-unresolved
import DropDownSelect from '../../../lib/DropDownSelect';

export default {
  components: {
    DropDownSelect,
  },
  props: {
    applyBoldStyle: {
      type: Function,
      default: () => 1,
    },
    applyItalicStyle: {
      type: Function,
      default: () => 1,
    },
    applyUnderlineStyle: {
      type: Function,
      default: () => 1,
    },
    fontSizeIdx: {
      type: Number,
      default: 0,
    },
    fontSizeList: {
      type: Array,
      default: () => [],
    },
    isBold: {
      type: Boolean,
      default: false,
    },
    isItalic: {
      type: Boolean,
      default: false,
    },
    isUnderline: {
      type: Boolean,
      default: false,
    },
    textAlign: {
      type: String,
      default: 'left',
    },
  },
  data () {
    return {
      colorPicker: {},
      currencyOptions: [
        ['General', 'c'], ['Custom', 'r'], ["$#,##0", "c0"], ['$#,##0.00', "c2"]
      ],
      applyFillColor: false,
    };
  },
  methods: {
    colorPickerInit(colorPicker) {
      const blurEvt = /firefox/i.test(window.navigator.userAgent) ? 'blur' : 'focusout';
      colorPicker.hostElement.addEventListener(blurEvt, () => {
        setTimeout(() => {
          if (!colorPicker.containsFocus()) {
            this.applyFillColor = false;
            colorPicker.hostElement.style.display = 'none';
          }
        }, 0);
      });
      colorPicker.valueChanged.addHandler(() => {
        if (this.applyFillColor) {
          this.$emit('set-background-color', colorPicker.value)
        } else {
          this.$emit('set-font-color', colorPicker.value)
        }
      });

      this.colorPicker = colorPicker;
    },
    fontSizeChanged(sender) {
      if (sender.selectedItem) {
        this.$emit('font-size-changed', sender.selectedItem.value)
      }
    },
    showColorPicker(e, isFillColor) {
      const he = this.colorPicker.hostElement;

      he.style.display = 'inline';
      he.style.position = 'fixed';
      const boundingRec = e.target.getBoundingClientRect();
      he.style.left = `${ boundingRec.left }px`;
      he.style.top = `${ boundingRec.top + boundingRec.height + 5 }px`;
      he.focus();

      this.applyFillColor = isFillColor;
    },
  },
}
</script>
