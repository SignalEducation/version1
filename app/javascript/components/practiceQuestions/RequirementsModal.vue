<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" :href="'#requirementsModal'+ requirementsInd" class="learn-more" data-backdrop="false" data-toggle="modal">
            <div class="circle"><span class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">assignment</i><p v-html="requirementsObj.name"></p></span>
        </button>
        <div @click="updateZindex()" :id="'requirementsModal'+ requirementsInd" class="modal2-solution fade resizemove-sol exhibits-modals" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <div class="modal2-header-lg">
                      <h4 v-html="requirementsObj.name" class="modal2-title"></h4>
                  </div>
                  <div class="modal2-body modal-inner-scroll">
                    <br>
                    <div>
                      <p v-html="requirementsObj.description"></p>
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
    requirementsObj: {
      type: [Object, Array],
    },
    requirementsInd: {
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
