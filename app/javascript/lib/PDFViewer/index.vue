<template>
  <div class="pdf-viewer">
    <header class="pdf-viewer__header box-shadow">
      <div class="pdf-preview-toggle">
        <a @click.prevent.stop="togglePreview" class="icon"><PreviewIcon /></a>
      </div>

      <PDFZoom
        :scale="scale"
        @change="updateScale"
        @fit="updateFit"
        class="header-item"
      />

      <PDFPaginator
        v-model="currentPage"
        :page-count="pageCount"
        class="header-item"
      />

      <slot name="header"></slot>
    </header>

    <PDFData
      class="pdf-viewer__main"
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
  </div>
</template>

<script>
import PreviewIcon from './assets/icon-preview.svg';
import PDFDocument from './components/PDFDocument.vue';
import PDFData from './components/PDFData.vue';
import PDFPaginator from './components/PDFPaginator.vue';
import PDFPreview from './components/PDFPreview.vue';
import PDFZoom from './components/PDFZoom.vue';

function floor(value, precision) {
  const multiplier = Math.pow(10, precision || 0);
  return Math.floor(value * multiplier) / multiplier;
}
export default {
  name: 'PDFViewer',
  components: {
    PDFDocument,
    PDFData,
    PDFPaginator,
    PDFPreview,
    PDFZoom,
    PreviewIcon,
  },
  props: {
    active: {
      type: Boolean,
      default: false,
    },
    fileUrl: {
      type: String,
      default: '',
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
  },
};
</script>

<style scoped>
header {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  padding: 1em;
  position: relative;
  z-index: 99;
  background-color: #525f69;
}
.header-item {
  margin: 0 2.5em;
}
.pdf-preview-toggle a {
  float: left;
  cursor: pointer;
  display: block;
  border: 1px #333 solid;
  background: white;
  color: #333;
  font-weight: bold;
  line-height: 1.5em;
  width: 1.5em;
  height: 1.5em;
  font-size: 1.5em;
  padding: 2px;
}
.pdf-preview-toggle > a.icon > svg {
  width: 30px;
  height: 30px;
  position: absolute;
}
.pdf-viewer {
  min-height: 500px;
  background-color: #525f69;
}
.pdf-viewer .pdf-viewer__document,
.pdf-viewer .pdf-viewer__preview {
  top: 108px;
}
.pdf-viewer__preview {
  display: block;
  width: 15%;
  right: 85%;
}
.pdf-viewer__document {
  top: 108px;
  width: 98%;
  left: 10px;
}
.pdf-viewer__document.preview-enabled {
  width: 84%;
  left: 15%;
}
@media print {
  header {
    display: none;
  }
}
</style>
