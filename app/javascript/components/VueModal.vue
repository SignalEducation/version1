<template>
  <modal :id="normId" class="latent-modal" :name="`modal-${componentType}-${componentName}`" draggable=".window-header" :height="componentHeight" :width="componentWidth">
    <div @click="makeActive(normId)" class="window-header latent-modal-header" :style="{ 'background-color':mainColor }">
      <p :style="{ 'color':textColor }">{{ componentName }}</p>
      <button @click="hide()" :style="{ 'color':textColor }" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
    </div>
    <div v-resize:debounce="onResize" @click="makeActive(normId)" class="vue-modal-body">
      Rohan
      <slot name="body" />
    </div>
  </modal>
</template>

<script>
import eventBus from "./cbe/EventBus.vue";
import pdfvuer from "pdfvuer";
import SpreadsheetEditor from "./SpreadsheetEditor/SpreadsheetEditor.vue";
import resize from 'vue-resize-directive';

export default {
  directives: {
    resize,
  },
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
      normId: this.normalizeId(`modal-${this.componentType}-${this.componentName}`)
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
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    });
    eventBus.$on("update-modal-z-index", (current_mod) => {
      this.makeActive(this.normalizeId(current_mod));
    });
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
    hide () {
      $('.latent-modal').removeClass('active-modal');
      eventBus.$emit("close-active-overlay", false);
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
    normalizeId (id) {
      var str = id.replace(/[!?()@#$%^&*]/g, "");
      return str.replace(/\s+/g, '-').toLowerCase();
    },
    makeActive(id) {
      $('.latent-modal').removeClass('active-modal');
      $("#"+id).addClass("active-modal");
    },
    onResize() {
      eventBus.$emit("refresh-spreadsheet-cells", true);
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
