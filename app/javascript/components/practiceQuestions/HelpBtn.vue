<template>
    <div>
        <button @click="show()" class="btn btn-settings help-btn-title components-sidebar-links" title="Help" data-backdrop="false" data-toggle="modal"></button>
        <VueModal
          :componentType="componentType"
          :componentName="componentName"
          :componentModal="componentModal"
          :mainColor="'rgba(24, 24, 66, 0.95)'"
          :textColor="'#ffffff'"
          :componentWidth="1000"
          :componentHeight="750"
        >
        <div slot="body">
          <div>
            <PDFViewer :active=true :file-url="helpPdf" class="pq-modal-pdf" />
          </div>
        </div>
      </VueModal>
    </div>
</template>

<script>

import PDFViewer from "../../lib/PDFViewer/index.vue";
import eventBus from "../cbe/EventBus.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    PDFViewer,
    eventBus,
    VueModal
  },
  data() {
    return {
      modalIsOpen: false,
    };
  },
  props: {
    helpPdf: String,
    componentType: {
      type: String,
      default: "navbar",
    },
    componentName: {
      type: String,
      default: "Help",
    },
    componentModal: {
      type: Boolean,
      default: true,
    },
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  mounted() {
    this.$nextTick(function () {
      $('#helpModal').draggable({ handle:'.modal2-header-lg, .draggable-overlay'});
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
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
  },
};
</script>