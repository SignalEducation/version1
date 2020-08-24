<template>
  <div>
    <section
      class="exhibits-sidebar-links exhibit-icon"
      @click="showModal = !showModal"
    >
      {{ exhibitName }}
    </section>

    <hsc-window-style-metal>
      <hsc-window
        :title="exhibitName"
        :closeButton="true"
        :isOpen.sync="showModal"
        :width="700"
        positionHint="center"
      >
        <PDFCourseViewer
          v-if="exhibitType === 'pdf'"
          :file-name="currentFile.name"
          :file-url="currentFile.url"
          :file-download="false"
        />
        <SpreadsheetEditor
          v-if="exhibitType === 'spreadsheet'"
          :initial-data="exhibitSpreadsheetData"
        />
      </hsc-window>
    </hsc-window-style-metal>
  </div>
</template>

<script>
import PDFCourseViewer from "../../lib/PDFCourseViewer/index.vue";
import VueWindow from "../VueWindow.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    PDFCourseViewer,
    SpreadsheetEditor,
    VueWindow,
  },
  props: {
    exhibitType: {
      type: String,
      default: "",
    },
    exhibitName: {
      type: String,
      default: "",
    },
    exhibitModal: {
      type: Boolean,
      default: false,
    },
    exhibitSpreadsheetData: {
      type: Object,
      default: () => ({}),
    },
    currentFile: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      showModal: this.exhibitModal,
    };
  },
};
</script>
