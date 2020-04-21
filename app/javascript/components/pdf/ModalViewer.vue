<template>
  <div id="cbe-modals" class="col-sm-6">
    <div class="card card-horizontal card-horizontal-sm flex-row"  @click="modalIsOpen = !modalIsOpen">
      <div
        class="card-header bg-white d-flex align-items-center justify-content-center"
      >
        <div>
          <i aria-label class="budicon-files-download" role="img"></i>
        </div>
      </div>
      <a href="#" class="card-body d-flex align-items-center pl-1">
        <h5 class="m-0 text-truncate text-gray2">
          {{ this.pdfFileName }}
        </h5>
      </a>
    </div>

    <div ref="resourcesModal" class="modal" v-show="modalIsOpen">
      <div class="modal-content resources-modal">
        <div class="modal-header bg-cbe-gray">
          <span class="title help-icon">
            {{ this.pdfFileName }}
          </span>

          <span class="close" @click="modalIsOpen = false">
            &times;
          </span>
        </div>

        <div class="modal-internal-content">
          <div id="resourceTabs">
            <PDFViewer :file-url="pdfFileUrl" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PDFViewer from "../../lib/PDFViewer/index.vue";

export default {
  components: {
    PDFViewer
  },
  data() {
    return {
      pdfFileName: this.$parent.fileName,
      pdfFileUrl: this.$parent.fileUrl,
      modalIsOpen: false
    };
  }
};
</script>
