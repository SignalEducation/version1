<template>
  <div
    id="cbe-modals"
    @click="sendToSegment()"
    class="col-md-4 col-lg-3 mb-4 px-3"
  >
    <div
      class="productCard internal-card"
      :class="this.hasValidSubscription && 'has-true-subscription'"
      @click="show('modal-' + componentType + '-' + pdfFileName)"
    >
      <div
        class="productCard-header d-flex align-items-center justify-content-center"
      >
        <AddonExamsIcon style="margin-bottom: -16px;" />
      </div>
      <div class="productCard-body d-flex align-items-center">
        <div>
          {{ this.pdfFileName }}
        </div>
        <div
          class="productCard-footer d-flex align-items-center justify-content-between"
        >
          <div>
            <span class="productCard-statusLabel">
              🎉 FREE
            </span>
          </div>
          <div class="btn btn-primary productCard--buyBtn">
            View
          </div>
        </div>
      </div>
    </div>
    <VueModal
      :componentType="componentType"
      :componentName="this.pdfFileName"
      :componentModal="componentModal"
      :componentHeight="550"
      :componentWidth="320"
    >
      <div slot="body">
        <div class="modal-internal-content">
          <div id="resourceTabs">
            <PDFCourseViewer
              :file-url="pdfFileUrl"
              :file-download="pdfFileDownload"
              :file-type="pdfFileType"
              @update-pages="updateViewedPages"
              :course-name="pdfCourseName"
              :program-name="pdfExamBodyName"
              :resource-name="pdfFileName"
              :email-verified="isEmailVerified"
            />
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
import AddonExamsIcon from "./addon-exams.svg";

export default {
  components: {
    PDFCourseViewer,
    VueModal,
    eventBus,
    AddonExamsIcon,
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
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    emailVerified: {
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
      pdfFileType: "resource",
      fileType: "PDF File",
      allowed: true,
      modalIsOpen: false,
      pdfCourseName: this.$parent.courseName,
      pdfCourseId: this.$parent.courseId,
      pdfExamBodyName: this.$parent.examBodyName,
      pdfExamBodyId: this.$parent.examBodyId,
      preferredExamBodyId: this.$parent.preferredExamBodyId,
      preferredExamBodyName: this.$parent.preferredExamBodyName,
      hasValidSubscription: this.$parent.hasValidSubscription,
      email: this.$parent.email,
      banner: this.$parent.banner,
      onboarding: this.$parent.onboarding,
    };
  },
  methods: {
    modalOpen(data) {
      this.modalIsOpen = true;
    },
    updateViewedPages(data) {
      const total = data.totalPages;
      const current = data.currentPage;

      if (current == total && !this.eventFired) {
        this.eventFired = true;
      }
    },
    sendToSegment() {
      sendClickEventToSegment("click_course_resources", {
        userId: userId,
        email: email,
        hasValidSubscription: this.hasValidSubscription,
        isEmailVerified: this.isEmailVerified,
        preferredExamBodyId: this.preferredExamBodyId,
        isLoggedIn: isLoggedIn,
        sessionId: sessionId,
        resourceName: this.pdfFileName,
        courseName: this.pdfCourseName,
        programName: this.pdfExamBodyName,
      });
    },
    show(modalId) {
      this.$modal.show("modal-" + this.componentType + "-" + this.pdfFileName);
      $(".components-sidebar .components div").removeClass("active-modal");
      setTimeout(() => {
        eventBus.$emit("update-modal-z-index", modalId);
      }, 100);
    },
    hide() {
      $(".latent-modal").removeClass("active-modal");
      this.$modal.hide("modal-" + this.componentType + "-" + this.pdfFileName);
    },
  },
};
</script>
