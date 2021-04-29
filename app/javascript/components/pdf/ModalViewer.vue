<template>
  <div id="cbe-modals" class="col-sm-6">
    <div class="card card-horizontal card-horizontal-sm flex-row" @click="show('modal-'+componentType+'-'+pdfFileName)">
      <div
        class="card-header bg-white d-flex align-items-center justify-content-center"
      >
        <div>
          <i aria-label class="budicon-files-download" role="img"></i>
        </div>
      </div>
      <a class="card-body d-flex align-items-center pl-1">
        <h5 class="m-0 text-truncate text-gray2">
          {{ this.pdfFileName }}
        </h5>
      </a>
    </div>
    <VueModal
      :componentType="componentType"
      :componentName="this.pdfFileName"
      :componentModal="componentModal"
      :componentHeight="550"
      :componentWidth="850"
    >
    <div slot="body">
      <div class="modal-internal-content">
        <div id="resourceTabs">
          <PDFCourseViewer :file-url="pdfFileUrl" :file-download="pdfFileDownload" :file-type="pdfFileType" @update-pages="updateViewedPages"/>
        </div>
      </div>
    </div>
  </VueModal>
  </div>
</template>

<script>
import PDFCourseViewer from "../../lib/PDFCourseViewer/index.vue";
import VueModal from "../VueModal.vue";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    PDFCourseViewer,
    VueModal,
    eventBus
  },
  props: {
    componentType: {
      type: String,
      default: "resources",
    },
    componentName: {
      type: String,
      default: "",
    },
    componentModal: {
      type: Boolean,
      default: false,
    },
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
    show (modalId) {
      this.$modal.show("modal-"+this.componentType+"-"+this.pdfFileName);
      $('.components-sidebar .components div').removeClass('active-modal');
      setTimeout(() => {
        eventBus.$emit("update-modal-z-index", modalId);
      }, 100);
    },
    hide () {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.pdfFileName);
    },

  }
};
</script>
