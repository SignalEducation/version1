<template>
  <div id="cbe-modals" class="col-sm-6" :style="{ zIndex: modalPos }">
    <div
      class="card card-horizontal card-horizontal-sm flex-row"
      @click="modalIsOpen = !modalIsOpen; zPos()"
    >
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
    <VueWindow
      v-if="modalIsOpen"
      :window-header="pdfFileName"
      :window-width="700"
      :window-height="300"
      :isResizable="true"
      :window-is-open="modalIsOpen"
      @updateWindowClose="handleChange"
      class="resource-modal-window"
    >
      <div
        slot="body"
      >
        <div id="resourceTabs">
          <PDFCourseViewer :file-url="pdfFileUrl" :file-download="pdfFileDownload" :file-type="pdfFileType" @update-pages="updateViewedPages"/>
        </div>
      </div>
    </VueWindow>
  </div>
</template>

<script>
import PDFCourseViewer from "../../lib/PDFCourseViewer/index.vue";
import VueWindow from 'components/VueWindow.vue'

export default {
  components: {
    PDFCourseViewer,
    VueWindow
  },
  data() {
    return {
      pdfFileName: this.$parent.fileName,
      pdfFileId: this.$parent.fileId,
      pdfFileUrl: this.$parent.fileUrl,
      pdfFileDownload: this.$parent.fileDownload,
      pdfFileType: 'resource',
      fileType: 'PDF File',
      allowed: true,
      modalIsOpen: false,
      modalPos: 1,
      modalIndex: this.$parent.modalIndex,
      pdfCourseName: this.$parent.courseName,
      pdfCourseId: this.$parent.courseId,
      pdfExamBodyName: this.$parent.examBodyName,
      pdfExamBodyId: this.$parent.examBodyId,
      preferredExamBodyId: this.$parent.preferredExamBodyId,
      preferredExamBodyName: this.$parent.preferredExamBodyName,
      banner: this.$parent.banner,
      onboarding: this.$parent.onboarding
    };
  },
  methods: {
    modalOpen(data) {
      this.modalIsOpen = true;
      courseResourceClick({preferredExamBodyId: this.preferredExamBodyId, preferredExamBody: this.preferredExamBodyName, banner: this.banner, onboarding: this.onboarding, resourceName: this.pdfFileName, resourceId: this.pdfFileId, courseName: this.pdfCourseName, courseId: this.pdfCourseId, examBodyName: this.pdfExamBodyName, examBodyId: this.pdfExamBodyId, resourceType: this.fileType, allowDownloadFile: this.allowed});
    },
    zPos() {
      this.modalPos = 2;
    },
    handleChange(value) {
      this.modalPos = 1;
      this.modalIsOpen = value
    },
    updateViewedPages(data) {
      const total   = data.totalPages;
      const current = data.currentPage;

      if ((current == total) && (!this.eventFired)) {
        courseResourceCompleted({preferredExamBodyId: this.preferredExamBodyId, preferredExamBody: this.preferredExamBodyName, banner: this.banner, onboarding: this.onboarding, resourceName: this.pdfFileName, resourceId: this.pdfFileId, courseName: this.pdfCourseName, courseId: this.pdfCourseId, examBodyName: this.pdfExamBodyName, examBodyId: this.pdfExamBodyId, resourceType: this.fileType, allowDownloadFile: this.allowed});
        this.eventFired = true;
      }
    },

  }
};
</script>
