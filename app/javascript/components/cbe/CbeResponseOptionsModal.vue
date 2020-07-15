<template>
  <div>
    <section :class="`exhibits-sidebar-links ${responseOptionType}-icon`" @click="showModal = !showModal">
      {{ responseOptionFType }}
    </section>


      <hsc-window-style-metal>
        <hsc-window
          :title="responseOptionFType"
          :closeButton="true"
          :isOpen.sync="showModal"
          :width="700"
          positionHint="center">

          <TinyEditor
            v-if="responseOptionType === 'open'"
            :field-model.sync="responseOption"
            :aditional-toolbar-options="[]"
            :editor-height="520" />

          <div v-if="responseOptionType === 'multiple_open'">
            <TinyEditor
            v-for="n in responseOptionQuantity"
            :key="n"
            :aditional-toolbar-options="[]"
            :editor-height="520" />
          </div>

          <SpreadsheetEditor
            v-if="responseOptionType === 'spreadsheet'"
            :initial-data="responseOption"
            @spreadsheet-updated="syncResponsesData" />
        </hsc-window>

      </hsc-window-style-metal>
  </div>
</template>

<script>
import VueWindow from '../VueWindow.vue'
import SpreadsheetEditor from '../SpreadsheetEditor/SpreadsheetEditor.vue';
import TinyEditor from "../TinyEditor.vue";

export default {
  components: {
    SpreadsheetEditor,
    VueWindow,
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
    responseOptionFType: {
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
      default:  false
    },
  },
  data() {
    return {
      showModal: this.responseOptionModal,
      responseOption: this.getInitialValue(),
    }
  },
  watch: {
    responseOption(newValue) {
      this.syncResponsesData(newValue)
    }
  },
  methods: {
    getInitialValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.responses[this.responseOptionId];

      if (initialValue != null) {
        switch(this.responseOptionType) {
          case 'open':
            return initialValue.response_attributes[0].content.data
            break;
          case 'multiple_open':
            return initialValue.response_attributes[0]
            break;
          case 'spreadsheet':
            return initialValue.response_attributes[0]
            break;
          default:
            return '';
        }
      }
    },
    syncResponsesData(newValue) {
      this.$store.dispatch("userCbe/recordResponse", {
        id: this.responseOptionId,
        cbe_response_option_id: this.responseOptionId,
        content: {
          data: newValue
        }
      });
    },
  },
};
</script>
