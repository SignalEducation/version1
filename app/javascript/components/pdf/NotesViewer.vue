<template>
  <PDFViewer :file-url="pdfFileUrl" @update-pages="updateNotesPages" />
</template>

<script>
import axios from "axios";
import PDFViewer from "../../lib/PDFViewer/index.vue";

export default {
  components: {
    PDFViewer
  },
  data() {
    return {
      pdfFileName: this.$parent.fileName,
      pdfFileUrl: this.$parent.fileUrl,
      userId: this.$parent.userId,
      courseId: this.$parent.courseId,
      stepLogId: this.$parent.stepLogId,
    };
  },
  methods: {
    updateNotesPages(data) {
      const total   = data.totalPages;
      const current = data.currentPage;

      if (current == total) {
        this.updateCourseStepLog();
      }
    },

    updateCourseStepLog() {
      document.getElementById("notes_next_lesson_navigation").classList.remove("hidden");
      axios
        .post( `/api/v1/courses/${this.courseId}/read_note_log/`, {
          step_log_id: this.stepLogId
        })
        .then(response => {
          console.log(response)
        })
        .catch(error => {
          console.log(error);
        });
    },
  },
};
</script>
