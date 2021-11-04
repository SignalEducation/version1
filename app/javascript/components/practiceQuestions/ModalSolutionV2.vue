<template>
  <div class="components-sidebar-links">
    <button
      id="modal-solution-v2"
      @click="show('modal-solution-v2')"
      class="cr-nav-link tool-btn"
    >
      Solution
    </button>
    <button v-if="loading" class="btn btn-settings solution-btn-title">
      <div class="vue-loader vue-loader-alt"></div>
    </button>
    <VueModal
      :componentType="componentType"
      :componentName="componentName"
      :componentModal="componentModal"
      :mainColor="'#00b67B'"
      :textColor="'#ffffff'"
    >
      <div slot="body">
        <div id="solutionModalV2" class="resizemove-sol">
          <div class="modal2-dialog">
            <div class="modal2-content">
              <div class="modal2-body">
                <div class="modal-solution-wrapper">
                  <ul class="tabs clearfix" data-tabgroup="first-tab-group">
                    <li
                      v-for="(solution, index) in solutionContentArray"
                      :key="convertObj2Str(solution)"
                    >
                      <a
                        v-if="solution.kind == 'open'"
                        :href="'#tab' + (index + 1)"
                        :class="{ 'active-sol': index == 0 }"
                      >
                        <i class="material-icons exhibits-icon">create</i>
                        <p v-html="solution.name"></p>
                      </a>
                      <a
                        v-else
                        :href="'#tab' + (index + 1)"
                        :class="{ 'active-sol': index == 0 }"
                      >
                        <i class="material-icons exhibits-icon">table_view</i>
                        <p v-html="solution.name"></p>
                      </a>
                    </li>
                  </ul>
                  <section id="first-tab-group" class="tabgroup">
                    <div
                      v-for="(solution, index) in solutionContentArray"
                      :key="convertObj2Str(solution)"
                      :id="'tab' + (index + 1)"
                      class="tabgroup-pad"
                      :class="{
                        'sol-open-size': solution.kind == 'open',
                        'sol-spreadsheet-size': solution.kind != 'open',
                      }"
                    >
                      <div v-if="solution.kind == 'open'">
                        <p v-html="solution.content"></p>
                      </div>
                      <div v-else>
                        <SpreadsheetEditor
                          :initial-data="convertStr2Obj(solution.content)"
                          :key="solution.id"
                          @spreadsheet-updated="syncSpreadsheetData"
                        />
                      </div>
                    </div>
                  </section>
                </div>
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
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    eventBus,
    SpreadsheetEditor,
    VueModal,
  },
  props: {
    solutionContentArray: {
      type: [Object, Array],
    },
    componentType: {
      type: String,
      default: "practice-question",
    },
    componentName: {
      type: String,
      default: "Solution",
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
      solutionObj: null,
      textBool: null,
      loading: false,
    };
  },
  async created() {
    eventBus.$on("close-modal", (status) => {
      this.modalIsOpen = status;
    });
  },
  mounted() {
    this.$nextTick(function() {
      $("#solutionModalV2").draggable({
        handle: ".modal2-header-lg, .draggable-overlay",
      });
    });
  },
  methods: {
    syncSpreadsheetData(jsonData) {},
    handleChange(value) {
      this.modalIsOpen = value;
    },
    instantiateTabs() {
      $(".tabgroup > div").hide();
      $(".tabgroup > div:first-of-type").show();
      $(".tabs a").click(function(e) {
        e.preventDefault();
        var $this = $(this),
          tabgroup = "#" + $this.parents(".tabs").data("tabgroup"),
          others = $this
            .closest("li")
            .siblings()
            .children("a"),
          target = $this.attr("href");
        others.removeClass("active-sol");
        $this.addClass("active-sol");
        $(tabgroup)
          .children("div")
          .hide();
        $(target).show();
      });
    },
    convertObj2Str(obj) {
      JSON.stringify(obj);
    },
    convertStr2Obj(str) {
      return JSON.parse(str);
    },
    show(id) {
      this.loading = true;
      $("#" + id).css("display", "none");
      setTimeout(() => {
        this.loading = false;
        $("#" + id).css("display", "block");
        this.$modal.show(
          "modal-" + this.componentType + "-" + this.componentName
        );
        $(".components-sidebar .components div").removeClass("active-modal");
        eventBus.$emit(
          "update-modal-z-index",
          `modal-${this.componentType}-${this.componentName}`
        );
      }, 10);
      setTimeout(() => {
        this.instantiateTabs();
      }, 750);
    },
    hide() {
      $(".latent-modal").removeClass("active-modal");
      this.$modal.hide(
        "modal-" + this.componentType + "-" + this.componentName
      );
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
