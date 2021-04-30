<template>
    <div>
        <button @click="show()" class="learn-more components-sidebar-links">
            <div class="circle"><span class="icon arrow"></span></div>
            <span class="button-text"><i class="material-icons exhibits-icon">create</i><p>Word Processor</p></span>
        </button>
        <VueModal
          :componentType="componentType"
          :componentName="componentName"
          :componentModal="componentModal"
        >
        <div slot="body">
          <div class="modal2-dialog">
            <div class="modal2-content">
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
        </div>
      </VueModal>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import PDFViewer from "../../lib/PDFViewer/index.vue";
import TinyEditor from '../TinyEditor.vue';
import VueModal from "../VueModal.vue";

export default {
  components: {
    eventBus,
    PDFViewer,
    TinyEditor,
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
      default: "Word Processor",
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
    show () {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
      eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
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
