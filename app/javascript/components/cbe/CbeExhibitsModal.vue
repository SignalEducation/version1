<template>
  <div>
    <section :id="'cbe-exhibit-modal-'+componentInd" @click="show('cbe-exhibit-modal-'+componentInd)" class="components-sidebar-links" :class="componentIcon">
      <div>{{ componentName }}<button v-if="loading" class="vue-loader vue-loader-cbe"></button></div>
    </section>
    <div>
      <VueModal
        :componentType="componentType"
        :componentName="componentName"
        :componentModal="componentModal"
        :componentSpreadsheetData="componentSpreadsheetData"
        :componentIcon="componentIcon"
        :height="450"
        :width="800"
      >
        <div slot="body">
          <SpreadsheetEditor
            v-if="componentType === 'spreadsheet'"
            :initial-data="componentSpreadsheetData"
          />
          <div id="pdfvuer" v-else-if="componentType === 'pdf'">
            <div
              id="buttons"
              class="ui grey three item inverted bottom fixed menu transition hidden"
            >
              <a class="item" @click="page > 1 ? page-- : 1">
                <i class="left chevron icon"></i>
                Back
              </a>
              <a class="ui active item">
                {{ page }} / {{ numPages ? numPages : "∞" }}
              </a>
              <a class="item" @click="page < numPages ? page++ : 1">
                Forward
                <i class="right chevron icon"></i>
              </a>
            </div>
            <div
              id="buttons"
              class="ui grey three item inverted bottom fixed menu transition hidden"
            >
              <a class="item" @click="scale -= scale > 0.2 ? 0.1 : 0">
                <i class="left chevron icon" />
                Zoom -
              </a>
              <a class="ui active item"> {{ formattedZoom }} % </a>
              <a class="item" @click="scale += scale < 2 ? 0.1 : 0">
                Zoom +
                <i class="right chevron icon" />
              </a>
            </div>
            <pdf
              :src="pdfdata"
              v-for="i in numPages"
              :key="i"
              :id="i"
              :page="i"
              :scale.sync="scale"
              style="width:100%;margin:0px auto;"
            >
              <template slot="loading">
                loading content here...
              </template>
            </pdf>
          </div>
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
    componentInd: {
      type: String,
      default: "",
    },
    componentModal: {
      type: Boolean,
      default: false,
    },
    componentSpreadsheetData: {
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
      loading: false
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

        if($("#buttons").length) {
          var sticky = $("#buttons")[0].offsetTop;
        }

        function stickyNav() {
          if($("#buttons").length) {
            if (window.pageYOffset >= sticky) {
              $("#buttons")[0].classList.remove("hidden");
            } else {
              $("#buttons")[0].classList.add("hidden");
            }
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
    show (id) {
      this.loading = true;
      setTimeout(() => {
      this.loading = false;
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
      eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
      }, 10);
    },
    hide (event) {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
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
