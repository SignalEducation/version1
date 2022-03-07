<template>
  <div>
    <section
      :id="'cbe-response-modal-' + responseOptionId"
      :class="`exhibits-sidebar-links ${responseOptionType}-icon`"
      @click="show('cbe-response-modal-' + responseOptionId)"
    >
      <div>
        {{ responseOptionName
        }}<button v-if="loading" class="vue-loader vue-loader-cbe"></button>
      </div>
    </section>
    <div>
      <VueModal
        :componentType="responseOptionType"
        :componentName="responseOptionName"
        :componentModal="responseOptionModal"
        :componentHeight="450"
        :componentWidth="800"
      >
        <div slot="body">
          <TinyEditor
            v-if="responseOptionType === 'open'"
            :field-model.sync="responseOption"
            :aditional-toolbar-options="[]"
            :editor-height="1200"
          />

          <div
            class="multiple-editors"
            v-if="responseOptionType === 'multiple_open'"
          >
            <div
              v-for="(response, index) in multipleResponseOption"
              :key="index"
            >
              <div class="slide-headers">Slide {{ index + 1 }}</div>
              <TinyEditor
                :field-model.sync="response.speaker"
                :aditional-toolbar-options="[]"
                :editor-height="520"
              />

              <div class="slide-headers">
                Slide {{ index + 1 }}: Speaker Notes
              </div>
              <TinyEditor
                :field-model.sync="response.notes"
                :aditional-toolbar-options="[]"
                :editor-height="520"
              />
            </div>
          </div>

          <SpreadsheetEditor
            v-if="responseOptionType === 'spreadsheet'"
            :initial-data="responseOption"
            :initialWidth="920"
            @spreadsheet-updated="syncResponsesData"
          />
        </div>
      </VueModal>
    </div>
  </div>
</template>

<script>
import eventBus from "./EventBus.vue";
import VueModal from "../VueModal.vue";
import SpreadsheetEditor from "../SpreadsheetEditor/SpreadsheetEditor.vue";
import TinyEditor from "../TinyEditor.vue";

export default {
  components: {
    SpreadsheetEditor,
    VueModal,
    TinyEditor,
  },
  props: {
    responseOptionId: {
      type: Number,
      default: null,
    },
    responseOptionType: {
      type: String,
      default: "",
    },
    responseOptionName: {
      type: String,
      default: "",
    },
    responseOptionQuantity: {
      type: Number,
      default: null,
    },
    responseOptionModal: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      lastTimeUpdated: new Date(),
      showModal: this.responseOptionModal,
      responseOption: this.getInitialValue(),
      multipleResponseOption: this.getInitialMultipleValue(
        this.responseOptionQuantity
      ),
      loading: false,
    };
  },
  watch: {
    responseOption(newValue, oldValue) {
      this.syncResponsesData(newValue, oldValue);
    },
    multipleResponseOption: {
      handler(newValue, oldValue) {
        this.syncResponsesData(newValue, oldValue);
      },
      deep: true,
    },
  },
  created() {
    eventBus.$on("close-modal", (status) => {
      this.showModal = status;
    });
  },
  mounted() {
    this.hide();
    eventBus.$on("response-opt-instant-update-sheet", (info) => {
      const currentData = {
        id: this.responseOptionId,
        cbe_response_option_id: this.responseOptionId,
        content: {
          data: info,
        },
      };
      if (info != null && this.responseOptionType === "spreadsheet") {
        this.responseOption = this.switchResponseOpt(currentData);
      }
    });
  },
  methods: {
    handleChange(value) {
      this.showModal = value;
    },
    switchResponseOpt(info) {
      let ans = "";
      if (info != null) {
        switch (this.responseOptionType) {
          case "open":
            ans = info.content.data;
            break;
          case "spreadsheet":
            ans = info;
            break;
          default:
            ans = "";
        }
      }
      return ans;
    },
    getInitialValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.responses[
        this.responseOptionId
      ];
      return this.switchResponseOpt(initialValue);
    },
    getInitialMultipleValue(quantity) {
      const initialValue = this.$store.state.userCbe.user_cbe_data.responses[
        this.responseOptionId
      ];

      let responses = [];
      let s_value = "";
      let n_value = "";
      let i = 0;

      while (i < quantity) {
        if (initialValue && initialValue.content.data[i].speaker) {
          s_value = initialValue.content.data[i].speaker;
        }
        if (initialValue && initialValue.content.data[i].notes) {
          n_value = initialValue.content.data[i].notes;
        }

        responses[i] = { speaker: s_value, notes: n_value };
        i++;
      }

      return responses;
    },
    syncResponsesData(newValue, oldValue) {
      const dateNow = new Date();
      const data = {
        id: this.responseOptionId,
        cbe_response_option_id: this.responseOptionId,
        content: {
          data: newValue,
        },
      };

      this.$store.dispatch("userCbe/recordResponse", data);
      // Update answers data if last update is more then 10 seconds OR new value is bigger then 20 characters.
      if (
        dateNow - this.lastTimeUpdated > 10000 ||
        newValue.length - oldValue.length > 20
      ) {
        this.lastTimeUpdated = dateNow;
        eventBus.$emit("update-question-answer", data);
      }
    },
    show(id) {
      this.loading = true;
      setTimeout(() => {
        this.loading = false;
        this.$modal.show(
          "modal-" + this.responseOptionType + "-" + this.responseOptionName
        );
        $(".components-sidebar .components div").removeClass("active-modal");
        eventBus.$emit(
          "update-modal-z-index",
          `modal-${this.responseOptionType}-${this.responseOptionName}`
        );
      }, 10);
    },
    hide() {
      this.$modal.hide(
        "modal-" + this.responseOptionType + "-" + this.responseOptionName
      );
    },
  },
};
</script>
<style lang="css">
.spread-host {
  height: 700px !important;
}
</style>
