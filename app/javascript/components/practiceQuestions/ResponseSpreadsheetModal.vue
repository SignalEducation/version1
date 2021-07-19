<template>
    <div>
        <button id="modal-response-spreadsheet" @click="show('modal-response-spreadsheet')" class="learn-more components-sidebar-links">
            <div class="circle"><span v-if="loading" class="vue-loader"></span><span v-if="!loading" class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">table_view</i><p>Spreadsheet</p></span>
        </button>
        <VueModal
          :componentType="componentType"
          :componentName="componentName"
          :componentModal="componentModal"
        >
        <div slot="body">
          <div class="modal2-content">
            <div class="modal2-body modal-inner-scroll">
              <br>
              <SpreadsheetEditor
                  :initial-data="responseObj.content"
                  :key="responseObj.id"
                  class="exhibits-spread-sheet"
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
    responseObj: {
      type: [Object, Array],
    },
    responseInd: {
      type: Number,
    },
    componentType: {
      type: String,
      default: "practice-question",
    },
    componentName: {
      type: String,
      default: "Spreadsheet",
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
      lastTimeUpdated: new Date(),
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
        $('#spreadsheetModal').draggable({ handle:'.modal2-header-lg, .draggable-overlay'});
    })
    //this.convertStr2Obj(this.responseObj)
    this.updateResponse()
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      this.responseObj.content = {
        content: {
          data: jsonData
        },
      };
    },
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit("z-index-click", 'spreadsheetModal');
    },
    show (id) {
      this.loading = true;
      setTimeout(() => {
        this.loading = false;
        this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
        $('.components-sidebar .components div').removeClass('active-modal');
        eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
      }, 10);
    },
    autoUpdateResponse: function(){
      const dateNow = new Date();

      // Update response data if last update is more then 10 seconds.
      if ((dateNow - this.lastTimeUpdated) > 10000  ) {
        this.lastTimeUpdated = dateNow;
        this.updateResponse();
      }
    },
    updateResponse() {
      eventBus.$emit("update-user-response");
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
    "responseObj.content": {
       handler() {
        this.autoUpdateResponse();
       },
      deep: true
    }
  },
};
</script>
