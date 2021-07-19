<template>
    <div>
        <button :id="'requirementsModal'+ requirementsInd" @click="show('requirementsModal'+ requirementsInd)" class="learn-more components-sidebar-links">
            <div class="circle"><span v-if="loading" class="vue-loader"></span><span v-if="!loading" class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">assignment</i><p v-html="requirementsObj.name"></p></span>
        </button>
        <VueModal
          :componentType="componentType"
          :componentName="requirementsObj.name"
          :componentModal="componentModal"
        >
        <div slot="body">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <div v-if="requirementsObj.kind == 'open'">
                  <p v-html="requirementsObj.description"></p>
                </div>
                <div v-else>
                  <p v-html="requirementsObj.description"></p>
                  <br>
                  <SpreadsheetEditor
                    :initial-data="requirementsObj.content"
                    :key="requirementsObj.id"
                    @spreadsheet-updated="syncSpreadsheetData"
                  />
                </div>
              </div>
          </div>
        </div>
      </VueModal>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import PDFViewer from "../../lib/PDFViewer/index.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
    PDFViewer,
    VueModal
  },
  props: {
    requirementsObj: {
      type: [Object, Array],
    },
    requirementsInd: {
      type: Number,
    },
    componentType: {
      type: String,
      default: "practice-question",
    },
    componentName: {
      type: String,
      default: "",
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
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  mounted() {
    this.$nextTick(function () {
        $('#requirementsModal'+this.requirementsInd).draggable({ handle:'.modal2-header-lg, .draggable-overlay-text'});
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
    updateZindex() {
      eventBus.$emit("z-index-click", `requirementsModal${this.requirementsInd}`);
    },
    resetModalDims() {
      $('#requirementsModal'+this.requirementsInd).css('width', '60em');
      $('#requirementsModal'+this.requirementsInd).css('height', '37em');
    },
    show (id) {
      this.loading = true;
      setTimeout(() => {
        this.loading = false;
        this.$modal.show("modal-"+this.componentType+"-"+this.requirementsObj.name);
        $('.components-sidebar .components div').removeClass('active-modal');
        eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.requirementsObj.name}`);
      }, 10);
    },
    hide () {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.requirementsObj.name);
    },
    convertStr2Obj(str) {
      console.log('str: ', str);
      return JSON.parse(str);
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
