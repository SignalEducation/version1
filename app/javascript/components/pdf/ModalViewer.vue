<template>
  <div id="cbe-modals" class="col-sm-6">
    <div class="card card-horizontal card-horizontal-sm flex-row"  @click="modalOpen">
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
            <PDFCourseViewer :file-url="pdfFileUrl" :file-download="pdfFileDownload" :file-type="pdfFileType" @update-pages="updateViewedPages"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PDFCourseViewer from "../../lib/PDFCourseViewer/index.vue";

export default {
  components: {
    PDFCourseViewer
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
