<template>
  <div id="cbe-modals">
    <b-nav-text
      title="Mark as Complete"
      class="submit-btn-title"
      @click="modalIsOpen = !modalIsOpen"
    >
    </b-nav-text>

    <VueWindow v-show="modalIsOpen"
      :window-header="'Submit Btn'"
      :window-width="520"
      :window-height="370"
      :window-is-open="modalIsOpen"
      @updateWindowClose="handleChange"
    >
      <div
        slot="body"
      >
      </div>
    </VueWindow>
  </div>
</template>

<script>
import Calculator from '../Calculator.vue';
import VueWindow from '../VueWindow.vue';

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
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    }
  },
};
</script>
