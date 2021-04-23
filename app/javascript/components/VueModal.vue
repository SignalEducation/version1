<template>
  <modal :name="`modal-${componentType}-${componentName}`" draggable=".window-header" :height="componentHeight" :width="componentWidth">
    <div @click="makeActiveHeader($event)" class="window-header" :style="{ 'background-color':mainColor }">
      <p :style="{ 'color':textColor }">{{ componentName }}</p>
      <button @click="hide($event)" :style="{ 'color':textColor }" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
    </div>
    <div @click="makeActiveBody($event)" class="latent-modal">
      <slot name="body" />
    </div>
  </modal>
</template>

<script>
import eventBus from "./cbe/EventBus.vue";
import pdfvuer from "pdfvuer";
import SpreadsheetEditor from "./SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    pdf: pdfvuer,
    SpreadsheetEditor,
  },
  props: {
    componentType: {
      type: String,
      default: "",
    },
    componentName: {
      type: String,
      default: "",
    },
    componentWidth: {
      type: Number,
      default: 800
    },
    componentHeight: {
      type: Number,
      default: 450
    },
    componentModal: {
      type: Boolean,
      default: false,
    },
    componentContentData: {
      type: Object,
      default: () => ({}),
    },
    componentIcon: {
      type: String,
      default: "",
    },
    windowIsOpen: {
      type: Boolean,
      default: false
    },
    mainColor: {
      type: String,
      default: "#F2F2F2",
    },
    textColor: {
      type: String,
      default: "#000000",
    },
  },
  data() {
    return {
      page: 1,
      numPages: 0,
      pdfdata: null,
      errors: [],
      scale: "page-width",
      showModal: this.componentModal,
      isOpen: false,
    };
  },
  computed: {
    formattedZoom() {
      return Number.parseInt(this.scale * 100);
    },
  },
  watch: {
    windowIsOpen: {
      immediate: true,
      handler(openValue) {
        this.isOpen = openValue;
      },
    },
    isOpen: {
      handler(openValue) {
        this.$emit('updateWindowClose', openValue);
      },
    },
  },
  created() {
    eventBus.$on("close-modal", (status) => {
      this.showModal = status;
    });
  },
  mounted() {

  },
  methods: {
    handleChange(value) {
      this.showModal = value;
      this.$emit("updateWindowClose", value);
    },
    findPos(obj) {
      return obj.offsetTop;
    },
    show (event) {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
    },
    hide (event) {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
    makeActiveHeader(event) {
      $('.components-sidebar .components div').removeClass('active-modal');
      event.target.parentElement.parentElement.parentElement.parentElement.classList.add('active-modal');
    },
    makeActiveBody(event) {
      $('.components-sidebar .components div').removeClass('active-modal');
      event.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.classList.add('active-modal');
    },
  },
};
</script>
<style lang="css" scoped>
#buttons {
  margin-left: 0 !important;
  margin-right: 0 !important;
}
/* Page content */
.content {
  padding: 16px;
}
</style>
