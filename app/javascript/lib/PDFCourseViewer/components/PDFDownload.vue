<template>
  <div class="pdf-download" v-if="fileDownload">
    <a @click.prevent.stop="downloadFile" class="icon">
      <i
        class="glyphicon glyphicon-download-alt"
        style="font-size: 12px;margin-right: 4px;color: #999999;"
      ></i>
      Download
    </a>
  </div>
</template>

<script>
export default {
  name: "PDFDownload",
  props: {
    fileUrl: {
      type: String,
    },
    fileName: {
      type: String,
    },
    courseName: {
      type: String,
    },
    programName: {
      type: String,
    },
    resourceName: {
      type: String,
    },
    fileType: {
      type: String,
    },
    fileDownload: {
      type: Boolean,
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
  },
  methods: {
    downloadFile() {
      if (document.getElementById("course-notes-anly")) {
        sendClickEventToSegment(
          "download_notes",
          getFileAttributes("course-notes-anly")
        );
      } else {
        sendClickEventToSegment("download_resources", {
          userId: userId,
          email: email,
          hasValidSubscription: this.hasValidSubscription,
          isEmailVerified: this.emailVerified,
          preferredExamBodyId: this.preferredExamBodyId,
          isLoggedIn: isLoggedIn,
          sessionId: sessionId,
          resourceName: this.resourceName,
          courseName: this.courseName,
          programName: this.programName,
        });
      }
      let link = document.createElement("a");
      link.href = this.fileUrl;
      link.target = "_blank";
      link.download = this.fileName;
      link.click();
      notesDownloadEvent(this.fileType);
    },
  },
};
</script>
