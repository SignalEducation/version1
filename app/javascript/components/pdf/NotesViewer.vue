<template>
  <div class="course-notes-reader">
    <PDFCourseViewer :file-name="pdfFileName" :file-url="pdfFileUrl"  :file-download="pdfFileDownload" @update-pages="updateNotesPages" />
  </div>
</template>

<script>
import axios from "axios";
import PDFCourseViewer from "../../lib/PDFCourseViewer/index.vue";

export default {
  components: {
    PDFCourseViewer
  },
  data() {
    return {
      pdfFileName: this.$parent.fileName,
      pdfFileUrl: this.$parent.fileUrl,
      pdfFileDownload: this.$parent.fileDownload,
      pdfFileType: 'note',
      userId: this.$parent.userId,
      courseId: this.$parent.courseId,
      stepLogId: this.$parent.stepLogId,
      eventFired: false,
    };
  },
  methods: {
    updateNotesPages(data) {
      const total   = data.totalPages;
      const current = data.currentPage;

      if (current == 1) {
        notesStartEvent();
      }

      if ((current == total) && (!this.eventFired)) {
        this.updateCourseStepLog();
        notesFinishEvent();
        this.eventFired = true;
      }
    },

    updateCourseStepLog() {
    axios
      .post( `/api/v1/courses/${this.courseId}/read_note_log/`, {
        step_log_id: this.stepLogId
      })
      .then(response => {
        document.getElementById("next-lesson-modal").classList.add("d-none");
        document.getElementById("next-lesson-link").classList.remove("d-none");

        console.log(response)
      })
      .catch(error => {
        console.log(error);
      });
    },
  },
};
</script>
