<template>
  <div id="cbe-modals">
    <b-nav-text
      class="help-btn-title"
      @click="modalIsOpen = !modalIsOpen"
    >
    </b-nav-text>

    <VueWindow v-show="modalIsOpen"
      :window-header="'Thirty'"
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
import Calculator from '../../components/Calculator.vue';
import VueWindow from '../../components/VueWindow.vue'

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
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
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
