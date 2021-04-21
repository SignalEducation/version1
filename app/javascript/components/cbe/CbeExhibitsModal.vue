<template>
  <div>
<<<<<<< HEAD
    <section
      class="exhibits-sidebar-links exhibit-icon"
      @click="show()"
    >
      {{ exhibitName }}
    </section>
    <modal :name="`cbe-exhibits-modal-${exhibitType}-${exhibitName}`" draggable=".window-header" scrollable=true resizable=true clickToClose=false>
      <div class="window-header">DRAG ME HERE</div>
      <button @click="hide()">CLOSE</button>
      <div>
        <SpreadsheetEditor
          v-if="exhibitType === 'spreadsheet'"
          :initial-data="exhibitSpreadsheetData"
        />
=======
    <section @click="show($event)" class="exhibits-sidebar-links exhibit-icon">
      {{ exhibitName }}
    </section>
    <div class="present-modal">
      <modal :name="`cbe-exhibits-modal-${exhibitType}-${exhibitName}`" draggable=".window-header" :scrollable="true" :resizable="false" :clickToClose="false">
        <div @click="makeActiveHeader($event)" class="window-header" :style="{ 'background-color':mainColor }">
          <p :style="{ 'color':textColor }">{{ exhibitName }}</p>
          <button @click="hide($event)" :style="{ 'color':textColor }" type="button" class="close modal-close modal-close-solution" data-dismiss="modal" aria-hidden="true">&times;</button>
        </div>
        <div @click="makeActiveBody($event)">
          <SpreadsheetEditor
            v-if="exhibitType === 'spreadsheet'"
            :initial-data="exhibitSpreadsheetData"
          />
>>>>>>> install and test new modal plugin

          <div id="pdfvuer" v-if="exhibitType === 'pdf'">
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
<<<<<<< HEAD
      </div>
    </modal>
=======
      </modal>
    </div>
>>>>>>> install and test new modal plugin
  </div>
</template>

<script>
import eventBus from "./EventBus.vue";
import pdfvuer from "pdfvuer";
import VueWindow from "../VueWindow.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";

export default {
  components: {
    pdf: pdfvuer,
    SpreadsheetEditor,
    VueWindow,
  },
  props: {
    exhibitType: {
      type: String,
      default: "",
    },
    exhibitName: {
      type: String,
      default: "",
    },
    exhibitModal: {
      type: Boolean,
      default: false,
    },
    exhibitSpreadsheetData: {
      type: Object,
      default: () => ({}),
    },
    currentFile: {
      type: Object,
      default: () => ({}),
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
      showModal: this.exhibitModal,
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
      this.$modal.show("cbe-exhibits-modal-"+this.exhibitType+"-"+this.exhibitName);
      $('.exhibits-sidebar .exhibits div').removeClass('active-modal');
    },
    hide (event) {
      $('.present-modal').removeClass('active-modal');
      this.$modal.hide("cbe-exhibits-modal-"+this.exhibitType+"-"+this.exhibitName);
    },
    makeActiveHeader(event) {
      $('.exhibits-sidebar .exhibits div').removeClass('active-modal');
      event.target.parentElement.parentElement.parentElement.parentElement.classList.add('active-modal');
    },
    makeActiveBody(event) {
      $('.exhibits-sidebar .exhibits div').removeClass('active-modal');
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
