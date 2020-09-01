<template>
  <div>
    <section
      class="exhibits-sidebar-links requirement-icon"
      @click="showModal = !showModal"
    >
      {{ `${requirementName} (${requirementScore} marks)` }}
    </section>
    <VueWindow
      :window-header="requirementName"
      :window-width="700"
      :window-is-open="showModal"
      :isResizable="true"
      :closeButton="true"
      @updateWindowClose="handleChange"
    >
      <div slot="body">
        <span v-html="requirementContent"></span>
      </div>
    </VueWindow>
  </div>
</template>

<script>
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
  methods: {
    handleChange(value) {
      this.showModal = value;
    },
  },
};
</script>
