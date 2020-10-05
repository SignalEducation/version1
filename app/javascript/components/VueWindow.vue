
<template>
  <hsc-window-style-metal>
    <hsc-window
      :close-button="true"
      :is-open.sync="isOpen"
      :resizable="isResizable"
      :width="windowWidth"
      :height="windowHeight"
      :title="windowHeader"
      position-hint="center"
    >
      <slot name="body" />

      <slot name="footer" />
    </hsc-window>
  </hsc-window-style-metal>
</template>

<script>
export default {
  props: {
    windowHeader: {
      type: String,
      default: ''
    },
    windowWidth: {
      type: Number,
      default: null
    },
    windowHeight: {
      type: Number,
      default: null
    },
    windowIsOpen: {
      type: Boolean,
      default: false
    },
    isResizable: {
      type: Boolean,
      default: false
    },
  },
  data() {
    return {
      isOpen: false,
    }
  },
  watch: {
    windowIsOpen: {
      immediate: true,
      handler(openValue) {
        this.isOpen = openValue;
      },
    },
    isOpen: {
      handler(openValue) {
        this.$emit('updateWindowClose', openValue);
      },
    },
  },
}
</script>
