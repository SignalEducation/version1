<template>
  <div class="btn-row">
    <div class="btn-group">
      <b-form-select
        :value="fontSizeIdx"
        class="font-size-select"
        :plain="true"
        :options="fontSizeList"
        @change="fontSizeChanged"
      />
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
      <chrome-picker
        v-if="colorPickerVisible"
        ref="colorPicker"
        v-on-clickaway="resetColorPicker"
        class="color-picker visible"
        :value="colors"
        @input="updateColorValue"
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
        :dropdown-options="[['General', 'General'], ['Custom', 'r'], ['#0.00', '#0.00'], ['#,##0', '#,##0'], ['#,##0.00', '#,##0.00']]"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'currency'"
        :dropdown-options="currencyOptions"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'percent'"
        :dropdown-options="[['0%', '#%'], ['0.00%', '#.00%'], ['0.0%', '#.0%']]"
        @selected-value-updated="(format) => $emit('number-format-changed', format)"
      />

      <DropDownSelect
        :icon-class="'fraction'"
        :dropdown-options="[['# ?/?', '# ?/?'], ['# ??/??', '# ??/??']]"
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
import { Chrome } from 'vue-color';
import { mixin as clickaway } from 'vue-clickaway';
import DropDownSelect from '../../../lib/DropDownSelect/index.vue';

const defaultProps = {
  hex: '#194d33e6',
  hsl: {
    h: 150,
    s: 0.5,
    l: 0.2,
    a: 0.9
  },
  hsv: {
    h: 150,
    s: 0.66,
    v: 0.30,
    a: 0.9
  },
  rgba: {
    r: 25,
    g: 77,
    b: 51,
    a: 0.9
  },
  a: 0.9
}


export default {
  components: {
    DropDownSelect,
    'chrome-picker': Chrome,
  },
  mixins: [ clickaway ],
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
      type: String,
      default: '12',
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
      colorPickerVisible: false,
      currencyOptions: [
        ['General', '$#0'], ['Custom', '$0'], ["$#,##0", "$#,##0"], ['$#,##0.00', "$#,##0.00"]
      ],
      applyFillColor: false,
      colors: defaultProps,
      fontSize: this.fontSizeIdx,
    };
  },
  methods: {
    resetColorPicker() {
      if (this.colorPickerVisible){
        this.applyFillColor = false;
        this.colorPickerVisible = false;
      }
    },
    updateColorValue (value) {
      if (this.applyFillColor) {
        this.$emit('set-background-color', value.hex);
      } else {
        this.$emit('set-font-color', value.hex);
      }
      this.colors = value;
    },
    fontSizeChanged(value) {
      this.$emit('font-size-changed', value)
    },
    showColorPicker(e, isFillColor) {
      this.colorPickerVisible = true;
      const boundingRec = e.target.getBoundingClientRect();

      setTimeout(() => {
        if(this.$refs.colorPicker) {
          const he = this.$refs.colorPicker.$el;
          he.style.left = `${ boundingRec.left }px`;
          he.style.top = `${ boundingRec.top + boundingRec.height + 5 }px`;
          he.focus();
          this.applyFillColor = isFillColor;
        }
      }, 0);
    },
  },
}
</script>
<style scoped>
  .font-size-select {
    width: 50px;
    margin-right: 10px;
  }
  .color-picker.visible {
    display: inline;
    position: fixed;
    z-index: 1;
  }
</style>
