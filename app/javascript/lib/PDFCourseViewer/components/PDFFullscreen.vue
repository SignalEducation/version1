<template>
  <div class="pdf-fullscreen">
    <a @click.prevent.stop="fullscreenWindow" class="icon">
      <i class="glyphicon glyphicon-fullscreen" style="font-size: 12px;margin-right: 4px;color: #999999;"></i>
      Fullscreen
    </a>
  </div>
</template>

<script>
export default {
  name: 'PDFFullscreen',
  methods: {
    fullscreenWindow() {
      this.$emit('presentationMode', true);
    },
  },
}
</script>
