<template>
  <div>
    <section @click="show($event)" class="components-sidebar-links" :class="componentIcon">
      {{ componentName }}
    </section>
    <div>
      <VueModal
        :componentType="componentType"
        :componentName="componentName"
        :componentModal="componentModal"
        :componentIcon="componentIcon"
        :componentHeight="450"
        :componentWidth="800"
      >
        <div slot="body">
          <span v-html="componentContentData"></span>
        </div>
      </VueModal>
    </div>
  </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    SpreadsheetEditor,
    VueModal
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
    componentModal: {
      type: Boolean,
      default: false,
    },
    componentContentData: {
      type: String,
      default: "",
    },
    componentIcon: {
      type: String,
      default: "",
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
    };
  },
  computed: {
    formattedZoom() {
      return Number.parseInt(this.scale * 100);
    },
  },
  created() {
    eventBus.$on("close-modal", (status) => {
      this.showModal = status;
    });
  },
  mounted() {
    if (this.currentFile) {
      this.getPdf();
    }
  },
  watch: {
    show: function(s) {
      if (this.currentFile) {
        this.getPdf();
      }
    },
    page: function(p) {
      if (
        window.pageYOffset <= this.findPos(document.getElementById(p)) ||
        (document.getElementById(p + 1) &&
          window.pageYOffset >= this.findPos(document.getElementById(p + 1)))
      ) {
        // window.scrollTo(0,this.findPos(document.getElementById(p)));
        document.getElementById(p).scrollIntoView();
      }
    },
  },
  methods: {
    handleChange(value) {
      this.showModal = value;
      this.$emit("updateWindowClose", value);
    },
    show (event) {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
      eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
    },
    hide (event) {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
    hide () {
      this.$modal.hide("cbe-requirements-modal-"+this.requirementName+"-"+this.requirementScore);
    }
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
