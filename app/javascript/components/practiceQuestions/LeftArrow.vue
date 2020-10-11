<template>
  <div id="cbe-modals">
    <b-nav-text
      v-if="showNavOptions(['questions'])"
      class="left-arrow-ques"
      @click="modalIsOpen = !modalIsOpen"
    >
    </b-nav-text>
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
