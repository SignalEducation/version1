<template>
    <div v-if="solutionContent[this.indexOfQuestion]">
      <button id="modal-solution-v1" @click="show('modal-solution-v1')" href="#solutionModal" class="btn btn-settings solution-btn-title components-sidebar-links">Solution</button>
      <button v-if="loading" class="btn btn-settings solution-btn-title"><div class="vue-loader vue-loader-alt"></div></button>
        <VueModal
          :componentType="componentType"
          :componentName="componentName"
          :componentModal="componentModal"
          :mainColor="'rgba(24, 24, 66, 0.95)'"
          :textColor="'#ffffff'"
        >
        <div slot="body">
          <div id="modal-solution-v1-inner-content">
            <h5>Question {{this.indexOfQuestion + 1}}</h5>
            <div v-if="solutionContent[this.indexOfQuestion].kind === 'open'">
              <p v-html="solutionContent[this.indexOfQuestion].solution"></p>
            </div>
            <div v-else>
              <SpreadsheetEditor
                  :initial-data="solutionContent[this.indexOfQuestion].solution"
                  :key="solutionContent[this.indexOfQuestion].id"
                  @spreadsheet-updated="syncSpreadsheetData"
              />

            </div>
        </div>
        </div>
      </VueModal>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
    VueModal
  },
  props: {
    solutionTitle: {
      type: String,
    },
    solutionContent: {
      type: [Object, Array],
    },
    componentType: {
      type: String,
      default: "practice-question",
    },
    componentName: {
      type: String,
      default: "Solution",
    },
    componentModal: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      modalIsOpen: false,
      indexOfQuestion: 0,
      solutionObj: null,
      loading: false
    };
  },
  async created() {
    eventBus.$on("active-solution-index", (showSubmitBtn) => {
      this.indexOfQuestion = showSubmitBtn[1];
      this.solutionObj = this.solutionContent[showSubmitBtn[1] - 1];
    });
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    });
  },
  mounted() {
    this.$nextTick(function () {
        $('#solutionModal').draggable({ handle:'.modal2-header-lg, .draggable-overlay'});
    })
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      this.solutionContent = {
        content: {
          data: jsonData
        },
      };
    },
    handleChange(value) {
      this.modalIsOpen = value;
    },
    show (id) {
      this.loading = true;
      $("#"+id).css("display","none");
      setTimeout(() => {
        this.loading = false;
        $("#"+id).css("display","block");
        this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
        $('.components-sidebar .components div').removeClass('active-modal');
        eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
      }, 10);
    },
    hide () {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
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
