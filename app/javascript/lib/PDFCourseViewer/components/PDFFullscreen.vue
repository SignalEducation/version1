<template>
  <div class="pdf-fullscreen">
    <a @click.prevent.stop="fullscreenWindow" class="icon material-icons">
      <i class="glyphicon glyphicon-fullscreen"></i>
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
