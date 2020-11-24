<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" href="#spreadsheetModal" class="learn-more" data-backdrop="false" data-toggle="modal">
            <div class="circle"><span class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">table_view</i><p>Spreadsheet</p></span>
        </button>
        <div @click="updateZindex()" id="spreadsheetModal" class="modal2-solution fade resizemove exhibits-modals" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <button @click="modalIsOpen = !modalIsOpen; updateResponse();" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <div class="modal2-header-lg">
                      <h4 class="modal2-title">Spreadsheet</h4>
                  </div>
                  <div class="modal2-body">
                    <br>
                    <SpreadsheetEditor
                        :initial-data="responseObj.content"
                        :key="responseObj.id"
                        @spreadsheet-updated="syncSpreadsheetData"
                    />
                </div>
              </div>
          </div>
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
    responseObj: {
      type: [Object, Array],
    },
    responseInd: {
      type: Number,
    },
  },
  data() {
    return {
      modalIsOpen: false,
      indexOfQuestion: 0,
      responseObj: null,
    };
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  mounted() {
    this.$nextTick(function () {
        $('#spreadsheetModal').draggable({ handle:'.modal2-header-lg'});
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
    resetModalDims() {
      $('#spreadsheetModal').css('width', '60em');
      $('#spreadsheetModal').css('height', '37em');
    },
    updateResponse() {
      eventBus.$emit("update-user-response");
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
