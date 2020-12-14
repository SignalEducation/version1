<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" :href="'#exhibitsModal'+ exhibitsInd" class="learn-more" data-backdrop="false" data-toggle="modal">
            <div class="circle"><span class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">description</i><p v-html="exhibitsObj.name"></p></span>
        </button>
        <div @click="updateZindex()" :id="'exhibitsModal'+ exhibitsInd" class="modal2-solution fade resizemove exhibits-modals" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <div class="modal2-header-lg">
                      <h4 v-html="exhibitsObj.name" class="modal2-title"></h4>
                  </div>
                  <div class="modal2-body">
                    <br>
                    <div v-show="exhibitsObj.kind === 'open'">
                      <p v-html="exhibitsObj.content"></p>
                    </div>
                    <div v-show="exhibitsObj.kind === 'spreadsheet'">
                      <SpreadsheetEditor
                          :initial-data="exhibitsObj.content"
                          :key="exhibitsObj.id"
                          @spreadsheet-updated="syncSpreadsheetData"
                      />
                    </div>
                    <div v-show="exhibitsObj.kind === 'document'">
                      <PDFViewer :active=true :file-url="exhibitsObj.document" />
                    </div>
                </div>
              </div>
          </div>
          <div class="draggable-overlay-text"></div>
        </div>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import PDFViewer from "../../lib/PDFViewer/index.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
    PDFViewer,
  },
  props: {
    exhibitsObj: {
      type: [Object, Array],
    },
    exhibitsInd: {
      type: Number,
    },
  },
  data() {
    return {
      modalIsOpen: false,
      indexOfQuestion: 0,
      solutionObj: null,
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
      eventBus.$emit("z-index-click", `exhibitsModal${this.exhibitsInd}`);
    },
    resetModalDims() {
      $('#exhibitsModal'+this.exhibitsInd).css('width', '60em');
      $('#exhibitsModal'+this.exhibitsInd).css('height', '37em');
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
