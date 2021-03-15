<template>
  <div>
    <section
      class="exhibits-sidebar-links requirement-icon"
      @click="show()"
    >
      {{ `${requirementName} (${requirementScore} marks)` }}
    </section>
    <modal :name="`cbe-requirements-modal-${requirementName}-${requirementScore}`" draggable=".window-header" scrollable=true resizable=true clickToClose=false>
      <div class="window-header">DRAG ME HERE</div>
        This is my first modal
      <button @click="hide()">CLOSE</button>
      <div>
        <span v-html="requirementContent"></span>
      </div>
    </modal>
  </div>
</template>

<script>
import eventBus from "./EventBus.vue";
import VueWindow from "../VueWindow.vue";

export default {
  components: {
    VueWindow,
  },
  props: {
    requirementScore: {
      type: Number,
      default: null,
    },
    requirementName: {
      type: String,
      default: "",
    },
    requirementContent: {
      type: String,
      default: "",
    },
    requirementModal: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      showModal: this.requirementModal,
    };
  },
  created() {
    eventBus.$on("close-modal", (status) => {
      this.showModal = status;
    });
  },
  methods: {
    handleChange(value) {
      this.showModal = value;
    },
    show () {
      this.$modal.show("cbe-requirements-modal-"+this.requirementName+"-"+this.requirementScore);
    },
    hide () {
      this.$modal.hide("cbe-requirements-modal-"+this.requirementName+"-"+this.requirementScore);
    }
  },
};
</script>
