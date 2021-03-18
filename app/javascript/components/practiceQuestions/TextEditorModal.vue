<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" href="#textEditorModal" class="learn-more" data-backdrop="false" data-toggle="modal">
            <div class="circle"><span class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">create</i><p>Word Processor</p></span>
        </button>
        <div @click="updateZindex()" id="textEditorModal" class="modal2-text-editor fade resizemove-sol text-editor-modal-sm" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <button @click="modalIsOpen = !modalIsOpen; updateResponse();" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <div class="modal2-header-lg">
                      <h4 class="modal2-title">Word Processor</h4>
                  </div>
                  <div class="modal2-body modal-inner-scroll">
                    <br>
                    <div>
                        <TinyEditor
                            :field-model.sync="responseObj.content"
                            :aditional-toolbar-options="['fullscreen code image']"
                            :editor-id="'introPagesEditor' + responseObj.id"
                        />
                    </div>
                </div>
              </div>
          </div>
          <div class="draggable-overlay"></div>
        </div>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import PDFViewer from "../../lib/PDFViewer/index.vue";
import TinyEditor from '../TinyEditor.vue';

export default {
  components: {
    eventBus,
    PDFViewer,
    TinyEditor,
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
      lastTimeUpdated: new Date(),
    };
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  mounted() {
    this.$nextTick(function () {
        $('#textEditorModal').draggable({ handle:'.modal2-header-lg, .draggable-overlay'});
    })
    this.updateResponse()
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit("z-index-click", 'textEditorModal');
    },
    resetModalDims() {
      $('#textEditorModal').css('width', '60em');
      $('#textEditorModal').css('height', '30em');
    },
    updateResponse() {
      if (this.responseObj.content !== "") {
        eventBus.$emit("show-submit-v2-btn", true);
        eventBus.$emit("active-solution-index-v2", true);
        eventBus.$emit("update-user-response");
      } else {
        eventBus.$emit("show-submit-v2-btn", false);
        eventBus.$emit("active-solution-index-v2", false);
        eventBus.$emit("update-user-response");
      }
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
      handler(newValue, oldValue) {
        const dateNow = new Date();

        // Update response data if last update is more then 10 seconds OR new value is bigger then 20 characters.
        if (dateNow - this.lastTimeUpdated > 10000 || (newValue.length - oldValue.length > 20)) {
          this.lastTimeUpdated = dateNow;
          this.updateResponse();
        }
      },
      deep: true
    }
  },
};
</script>
