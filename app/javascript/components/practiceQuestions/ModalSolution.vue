<template>
    <div>
      <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" href="#solutionModal" class="btn btn-settings solution-btn-title" data-backdrop="false" data-toggle="modal">Solution</button>
      <div @click="updateZindex()" id="solutionModal" class="modal2-solution fade resizemove" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <div class="modal2-header-lg">
                      <h4 class="modal2-title">Solution</h4>

                  </div>
                  <div class="modal2-body">
                    <div>
                      <h5>Question {{this.indexOfQuestion + 1}}</h5>
                      <div v-show="solutionContent[this.indexOfQuestion].kind === 'spreadsheet'">
                        <SpreadsheetEditor
                            :initial-data="solutionContent[this.indexOfQuestion].solution"
                            :key="solutionContent[this.indexOfQuestion].id"
                            @spreadsheet-updated="syncSpreadsheetData"
                        />

                      </div>
                      <div v-show="solutionContent[this.indexOfQuestion].kind === 'open'">
                        <p v-html="solutionContent[this.indexOfQuestion].solution"></p>
                      </div>
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
        $('#solutionModal').draggable({ handle:'.modal2-header-lg'});
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
      eventBus.$emit("z-index-click", "solutionModal");
    },
    resetModalDims() {
      $('#solutionModal').css('width', '60em');
      $('#solutionModal').css('height', '37em');
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
