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
  methods: {
    handleChange(value) {
      this.modalIsOpen = value
    }
  },
};
</script>
