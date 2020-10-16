<template>
  <div>
    <button
      @click="
        modalIsOpen = !modalIsOpen;
        updateZindex();
      "
      href="#solutionModal"
      class="btn btn-settings solution-btn-title"
      data-backdrop="false"
      data-toggle="modal"
    >
      Solution
    </button>
    <div
      @click="updateZindex()"
      id="solutionModal"
      class="modal2-solution fade"
      v-show="modalIsOpen"
    >
      <div class="modal2-dialog">
        <div class="modal2-content">
          <button
            @click="modalIsOpen = !modalIsOpen"
            type="button"
            class="close modal-close"
            data-dismiss="modal"
            aria-hidden="true"
          >
            &times;
          </button>
          <div class="modal2-header">
            <h4 class="modal2-title">Solution</h4>
          </div>
          <div class="modal2-body">
            <h3>{{ solutionTitle }}</h3>
            <h5>Question {{ this.indexOfQuestion + 1 }}</h5>
            <div v-if="solutionObj.kind === 'spreadsheet'"></div>
            <div v-else>
              <p v-html="solutionObj.solution"></p>
            </div>
            <div v-show="solutionObj.kind == 'open'">
              <p v-html="solutionObj.solution"></p>
            </div>
            <div v-show="solutionObj.kind == 'spreadsheet'">
              <SpreadsheetEditor
                :initial-data="solutionObj.solution"
                :key="solutionObj.id"
                @spreadsheet-updated="syncSpreadsheetData"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
  },
  props: {
    solutionTitle: {
      type: String,
    },
    solutionContent: {
      type: [Object, Array],
    },
  },
  data() {
    return {
      modalIsOpen: false,
      indexOfQuestion: 0,
      solutionObj: null,
    };
  },
  async created() {
    eventBus.$on("active-solution-index", (index) => {
      this.indexOfQuestion = index;
      this.solutionObj = this.solutionContent[index - 1];
    });
  },
  mounted() {
    this.$nextTick(function() {
      $("#solutionModal").draggable();
    });
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit("z-index-click", "solutionModal");
    },
  },
  watch: {
    modalStatus(status) {
      this.modalIsOpen = status;
    },
    modalIsOpen(value) {
      this.$emit("update-close-all", this.modalIsOpen);
    },
  },
};
</script>
