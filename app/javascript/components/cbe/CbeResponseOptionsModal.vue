<template>
  <div>
    <section
      :class="`exhibits-sidebar-links ${responseOptionType}-icon`"
      @click="show()"
    >
      {{ responseOptionName }}
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
            <div v-for="(response, index) in multipleResponseOption" :key="index">
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
      showModal: this.responseOptionModal,
      responseOption: this.getInitialValue(),
      multipleResponseOption: this.getInitialMultipleValue(
        this.responseOptionQuantity
      ),
    };
  },
  watch: {
    responseOption(newValue) {
      this.syncResponsesData(newValue);
    },
    multipleResponseOption: {
      handler(newValue) {
        this.syncResponsesData(newValue);
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
  },
  methods: {
    handleChange(value) {
      this.showModal = value;
    },
    getInitialValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.responses[
        this.responseOptionId
      ];

      if (initialValue != null) {
        switch (this.responseOptionType) {
          case "open":
            return initialValue.content.data;
            break;
          case "spreadsheet":
            return initialValue;
            break;
          default:
            return "";
        }
      }
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
    syncResponsesData(newValue) {
      this.$store.dispatch("userCbe/recordResponse", {
        id: this.responseOptionId,
        cbe_response_option_id: this.responseOptionId,
        content: {
          data: newValue,
        },
      });
    },
    show () {
      this.$modal.show("modal-"+this.responseOptionType+"-"+this.responseOptionName);
    },
    hide () {
      this.$modal.hide("modal-"+this.responseOptionType+"-"+this.responseOptionName);
    }
  },
};
</script>
<style lang="css">
.spread-host {
  height: 700px !important;
}
</style>
