<template>
    <div>
        <button :id="'exhibitsModal'+ exhibitsInd" @click="show('exhibitsModal'+ exhibitsInd)" class="learn-more components-sidebar-links">
          <div class="circle"><span class="icon arrow"></span></div>
          <span class="button-text"><i class="material-icons exhibits-icon">description</i><p v-html="exhibitsObj.name"></p></span>
        </button>
        <button v-if="loading" class="vue-loader"></button>
        <VueModal
          :componentType="componentType"
          :componentName="exhibitsObj.name"
          :componentModal="componentModal"
        >
        <div slot="body">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <div v-if="exhibitsObj.kind === 'open'">
                  <p v-html="exhibitsObj.content"></p>
                </div>
                <div v-if="exhibitsObj.kind === 'spreadsheet'">
                  <SpreadsheetEditor
                      :initial-data="convertStr2Obj(exhibitsObj.content)"
                      :key="exhibitsObj.id"
                      class="exhibits-spread-sheet"
                      @spreadsheet-updated="syncSpreadsheetData"
                  />
                </div>
                <div v-else>
                  <PDFViewer :active=true :file-url="exhibitsObj.document" class="pq-modal-pdf" />
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
    exhibitsObj: {
      type: [Object, Array],
    },
    exhibitsInd: {
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
        $('#exhibitsModal'+this.exhibitsInd).draggable({ handle:'.modal2-header-lg, .draggable-overlay-text'});
    })
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      this.exhibitsObj = {
        content: {
          data: jsonData
        },
      };
    },
    handleChange(value) {
      this.modalIsOpen = value;
    },
    convertStr2Obj(str) {
      return JSON.parse(str);
    },
    show (id) {
      this.loading = true;
      $("#"+id).css("display","none");
      setTimeout(() => {
        this.loading = false;
        $("#"+id).css("display","block");
        this.$modal.show("modal-"+this.componentType+"-"+this.exhibitsObj.name);
        $('.components-sidebar .components div').removeClass('active-modal');
        eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.exhibitsObj.name}`);
      }, 10);
    },
    hide () {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.exhibitsObj.name);
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
