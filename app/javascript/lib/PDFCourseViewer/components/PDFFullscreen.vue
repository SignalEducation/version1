<template>
  <div class="pdf-fullscreen">
    <a 
      class="icon"
      @click="fullscreenWindow" 
    >
      <i 
        class="glyphicon glyphicon-fullscreen" 
        style="font-size: 12px;margin-right: 4px;color: #999999;" 
      />
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
