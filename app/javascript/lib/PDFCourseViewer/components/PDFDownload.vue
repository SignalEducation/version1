<template>
  <div class="pdf-download" v-if="fileDownload">
    <a @click.prevent.stop="downloadFile" class="icon">
      <i class="glyphicon glyphicon-download-alt" style="font-size: 12px;margin-right: 4px;color: #999999;"></i>
      Download
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
    fileType: {
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
      link.target   = '_blank';
      link.download = this.fileName;
      link.click();
      notesDownloadEvent(this.fileType);
    },
  },
}
</script>
