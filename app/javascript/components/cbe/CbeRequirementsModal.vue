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
        :componentContentData="componentContentData"
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
import pdfvuer from "pdfvuer";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    pdf: pdfvuer,
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
      type: Object,
      default: () => ({}),
    },
    currentFile: {
      type: Object,
      default: () => ({}),
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
    getPdf() {
      var self = this;
      self.pdfdata = pdfvuer.createLoadingTask(self.currentFile.url);
      self.pdfdata.then((pdf) => {
        self.numPages = pdf.numPages;
        window.onscroll = function() {
          changePage();
          stickyNav();
        };

        // Get the offset position of the navbar
        var sticky = $("#buttons")[0].offsetTop;

        // Add the sticky class to the self.$refs.nav when you reach its scroll position. Remove "sticky" when you leave the scroll position
        function stickyNav() {
          if (window.pageYOffset >= sticky) {
            $("#buttons")[0].classList.remove("hidden");
          } else {
            $("#buttons")[0].classList.add("hidden");
          }
        }

        function changePage() {
          var i = 1,
            count = Number(pdf.numPages);
          do {
            if (
              window.pageYOffset >= self.findPos(document.getElementById(i)) &&
              window.pageYOffset <= self.findPos(document.getElementById(i + 1))
            ) {
              self.page = i;
            }
            i++;
          } while (i < count);
          if (window.pageYOffset >= self.findPos(document.getElementById(i))) {
            self.page = i;
          }
        }
      });
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