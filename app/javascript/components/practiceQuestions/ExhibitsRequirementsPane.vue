<template>
  <section>
    <div class="practice-question-V2" style="padding:15px;">
      <div class="practice-question-section">
        <div class="practice-question-v2-title">Exhibits</div>
        <div v-for="(task, index) in exhibitContentArray" :key="task">
          <ExhibitsModal :exhibitsObj="exhibitContentArray[index]" :exhibitsInd="index" />
        </div>
      </div>
      <div class="practice-question-section">
        <div class="practice-question-v2-title">Requirements</div>
        <div v-for="(task, index) in requirementContentArray" :key="task">
          <RequirementsModal :requirementsObj="requirementContentArray[index]" :requirementsInd="index" />
        </div>
      </div>
      <div class="practice-question-section">
        <div class="practice-question-v2-title">Response Options</div>
        <span v-for="(task, index) in requirementContentArray" :key="task">
          <span v-if="responseContentArray[index].kind == 'open'">
            <TextEditorModal :responseObj="responseContentArray[index]" :responseInd="index" />
          </span>
          <span v-else>
            <ResponseSpreadsheetModal :responseObj="responseContentArray[index]"  :responseInd="index" />
          </span>
        </span>
      </div>
    </div>
  </section>
</template>

<script>

function rightPaneScrolling() {
  let isScrolling;
  if ($("#pane_1").scrollTop() == 0) {
    setTimeout(() => {
      document.getElementById("rightPaneTopUnderline").style.display = "none";
    }, 500);
  }
  document.getElementById("rightPaneTopUnderline").style.display = "block";
  window.clearTimeout( isScrolling );
}

import axios from "axios";
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import ExhibitsModal from "./ExhibitsModal.vue";
import RequirementsModal from "./RequirementsModal.vue";
import TextEditorModal from "./TextEditorModal.vue";
import ResponseSpreadsheetModal from "./ResponseSpreadsheetModal.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
    ExhibitsModal,
    RequirementsModal,
    TextEditorModal,
    ResponseSpreadsheetModal,
  },
  props: {
    exhibitContentArray: {
      type: Array,
    },
    requirementContentArray: {
      type: Array,
    },
    responseContentArray: {
      type: Array,
    },
    practiceQuestionId: {
      type: [String, Number],
    },
    stepLogId: {
      type: [String, Number],
    },
  },
  data() {
    return {
      modalIsOpen: false,
      activePage: 1,
      isActive: true,
      questionContent: null,
      fillArr: null,
    };
  },
  mounted() {
    document.querySelector('#pane_1').style.width = '80%';
    document.querySelector('#pane_1').addEventListener("scroll", rightPaneScrolling);
  },
  async created() {
    this.questionContent = this.exhibitContentArray[this.activePage - 1];
    eventBus.$on("update-user-response",()=>{
      this.updateCurrentResponse();
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    updateCurrentResponse: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            responses: this.responseContentArray,
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
  },
};
</script>
