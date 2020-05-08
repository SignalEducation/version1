<template>
  <div class="pdf-zoom">
    <a @click.prevent.stop="zoomIn" class="icon material-icons" :disabled="isDisabled">
       <i class="glyphicon glyphicon-plus"></i>
    </a>

    <a @click.prevent.stop="zoomOut" class="icon material-icons" :disabled="isDisabled">
      <i class="glyphicon glyphicon-minus"></i>
    </a>

    <a @click.prevent.stop="fitWidth" class="icon material-icons" :disabled="isDisabled">
      <i class="glyphicon glyphicon-resize-full"></i>
    </a>

    <a @click.prevent.stop="fitAuto" class="icon material-icons" :disabled="isDisabled">
      <i class="glyphicon glyphicon-resize-small"></i>
    </a>
  </div>
</template>

<script>

export default {
  name: 'PDFZoom',
  props: {
    scale: {
      type: Number,
    },
    increment: {
      type: Number,
      default: 0.25,
    },
  },
  computed: {
    isDisabled() {
      return !this.scale;
    },
  },
  methods: {
    zoomIn() {
      this.updateScale(this.scale + this.increment);
    },
    zoomOut() {
      if (this.scale <= this.increment) return;
      this.updateScale(this.scale - this.increment);
    },
    updateScale(scale) {
      this.$emit('change', {scale});
    },
    fitWidth() {
      this.$emit('fit', 'width');
    },
    fitAuto() {
      this.$emit('fit', 'auto');
    },
  },
}
</script>

<style scoped>
.toolbarButton, .dropdownToolbarButton, .secondaryToolbarButton, .overlayButton {
    min-width: 16px;
    padding: 2px 6px 0;
    border: 1px solid rgba(0, 0, 0, 0);
    border-radius: 2px;
    color: rgba(255, 255, 255, 0.8);
    font-size: 12px;
    line-height: 14px;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    cursor: default;
}

.toolbarButton:hover, .toolbarButton:focus {
  background-color: rgba(0, 0, 0, 0.12);
  background-image: linear-gradient(rgba(255, 255, 255, 0.05), rgba(255, 255, 255, 0));
  background-clip: padding-box;
  border: 1px solid rgba(0, 0, 0, 0.35);
  border-color: rgba(0, 0, 0, 0.32) rgba(0, 0, 0, 0.38) rgba(0, 0, 0, 0.42);
  box-shadow: 0 1px 0 rgba(255, 255, 255, 0.05) inset, 0 0 1px rgba(255, 255, 255, 0.15) inset, 0 1px 0 rgba(255, 255, 255, 0.05);
}
</style>
