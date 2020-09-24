<template>
  <div id="cbe-modals">
    <b-nav-text
      class="calculator-icon"
      @click="modalIsOpen = !modalIsOpen"
    >
      Calculator
    </b-nav-text>

    <VueWindow
      :window-header="'Calculator'"
      :window-width="520"
      :window-height="370"
      :window-is-open="modalIsOpen"
      @updateWindowClose="handleChange"
    >
      <div
        slot="body"
      >
        <Calculator />
      </div>
    </VueWindow>
  </div>
</template>

<script>
import Calculator from '../Calculator.vue';
import VueWindow from '../VueWindow.vue'

export default {
  components: {
    Calculator,
    VueWindow,
  },
  data() {
    return {
      modalIsOpen: false,
    };
  },
  props:{
    modalStatus: {
      type: Boolean,
      default: null,
    },
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    }
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
