<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" href="#textEditorModal" class="learn-more" data-backdrop="false" data-toggle="modal">
            <div class="circle"><span class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">create</i><p>Word Processor</p></span>
        </button>
        <div @click="updateZindex()" id="textEditorModal" class="modal2-text-editor fade resizemove text-editor-modal-sm" v-show="modalIsOpen">
          <div class="modal2-dialog">
              <div class="modal2-content">
                <button @click="modalIsOpen = !modalIsOpen; updateResponse();" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <div class="modal2-header-lg">
                      <h4 class="modal2-title">Word Processor</h4>
                  </div>
                  <div class="modal2-body">
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
        $('#textEditorModal').draggable({ handle:'.modal2-header-lg'});
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
  },
};
</script>
