<template>
  <div class="pdf-viewer">
    <header class="pdf-viewer__header box-shadow">
      <div class="pdf-preview-toggle toolbarButton">
        <a @click.prevent.stop="togglePreview" class="icon material-icons">
          <i class="glyphicon glyphicon-list-alt"></i>
        </a>
      </div>

      <PDFPaginator
        v-model="currentPage"
        :page-count="pageCount"
        class=""
      />

       <PDFZoom
        :scale="scale"
        @change="updateScale"
        @fit="updateFit"
        class="toolbarButton"
      />

      <PDFFullscreen
        @presentationMode="enablePresentation"
        @fit="updateFit"
        class="toolbarButton"
      />

      <PDFDownload
        :file-download="fileDownload"
        :file-name="fileName"
        :file-url="fileUrl"
        :file-type="fileUrl"
        class="toolbarButton"
      />

      <slot name="header"></slot>
    </header>

    <fullscreen ref="fullscreen" @change="fullscreenChange">
      <PDFData
        class="pdf-viewer__main"
        v-bind:style="pdfStyleObject"
        :url="fileUrl"
        @page-count="updatePageCount"
        @page-focus="updateCurrentPage"
        @document-rendered="onDocumentRendered"
        @document-errored="onDocumentErrored"
      >
        <template v-slot:preview="{pages}">
          <PDFPreview
            v-show="isPreviewEnabled"
            class="pdf-viewer__preview"
            v-bind="{pages, scale, currentPage, pageCount, isPreviewEnabled}"
          />
        </template>

        <template v-slot:document="{pages}">
          <PDFDocument
            class="pdf-viewer__document"
            :class="{ 'preview-enabled': isPreviewEnabled }"
            v-bind="{pages, scale, optimalScale, fit, currentPage, pageCount, isPreviewEnabled}"
            @scale-change="updateScale"
          />
        </template>
      </PDFData>
    </fullscreen>
  </div>
</template>

<script>
import PDFData from './components/PDFData.vue';
import PDFDocument from './components/PDFDocument.vue';
import PDFDownload from './components/PDFDownload.vue';
import PDFFullscreen from './components/PDFFullscreen.vue';
import PDFPaginator from './components/PDFPaginator.vue';
import PDFPreview from './components/PDFPreview.vue';
import PDFZoom from './components/PDFZoom.vue';

function floor(value, precision) {
  const multiplier = Math.pow(10, precision || 0);
  return Math.floor(value * multiplier) / multiplier;
}
export default {
  name: 'PDFCourseViewer',
  components: {
    PDFData,
    PDFDocument,
    PDFDownload,
    PDFFullscreen,
    PDFPaginator,
    PDFPreview,
    PDFZoom,
  },
  props: {
    active: {
      type: Boolean,
      default: false,
    },
    fileName: {
      type: String,
      default: '',
    },
    fileUrl: {
      type: String,
      default: '',
    },
    fileType: {
      type: String,
      default: '',
    },
    fileDownload: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      scale: 1.5,
      optimalScale: 1.5,
      fit: undefined,
      currentPage: 1,
      pageCount: undefined,
      isPreviewEnabled: false,
      fullscreen: false,
      pdfStyleObject: {},
    };
  },
  watch: {
    url() {
      this.currentPage = undefined;
    },
  },
  methods: {
    onDocumentRendered() {
      this.$emit('document-rendered', this.url);
    },
    onDocumentErrored(e) {
      this.$emit('document-errored', e);
    },
    updateScale({scale, isOptimal = false}) {
      const roundedScale = floor(scale, 2);
      if (isOptimal) this.optimalScale = roundedScale;
      this.scale = roundedScale;
    },
    updateFit(fit) {
      this.fit = fit;
    },
    updatePageCount(pageCount) {
      this.pageCount = pageCount;
    },
    updateCurrentPage(pageNumber) {
      this.currentPage = pageNumber;
      this.updateNotesPages(pageNumber, this.pageCount);
    },
    updateNotesPages(page, total){
      this.$emit('update-pages', { currentPage: this.currentPage, totalPages: this.pageCount });
    },
    togglePreview() {
      this.isPreviewEnabled = !this.isPreviewEnabled;
    },
    enablePresentation(value){
      this.toggleFullscreen()
    },
    toggleFullscreen () {
      this.$refs['fullscreen'].toggle();
    },
    fullscreenChange (fullscreen) {
      this.fullscreen = fullscreen
    },
  },
};
</script>
