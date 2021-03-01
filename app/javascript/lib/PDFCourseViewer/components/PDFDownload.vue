<template>
  <div class="pdf-download" v-if="fileDownload">
    <a @click.prevent.stop="downloadFile" class="icon material-icons">
      <i class="glyphicon glyphicon-download-alt"></i>
    </a>
  </div>
</template>

<script>
export default {
  name: 'PDFDownload',
  props: {
    fileUrl: {
      type: String,
    },
    fileName: {
      type: String,
    },
    fileDownload: {
      type: Boolean,
    },
  },
  methods: {
    downloadFile() {
      let link      = document.createElement("a");
      link.href     = this.fileUrl;
      link.target   = '_blank'
      link.download = this.fileName;
      link.click();
      notesDownloadEvent();
    },
  },
}
</script>
