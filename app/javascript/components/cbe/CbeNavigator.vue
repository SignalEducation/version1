<template>
  <div id="cbe-modals">
    <b-nav-text
      class="navigation-icon"
      ref="myBtn"
      v-on:click="modalIsOpen = !modalIsOpen"
      >Navigator</b-nav-text
    >

    <div ref="myModal" class="modal" v-show="modalIsOpen">
      <div class="modal-content">
        <div class="modal-header bg-cbe-gray">
          <span class="title navigation-icon">
            Navigator - select a question to go to it
          </span>

          <span class="close" v-on:click="modalIsOpen = !modalIsOpen">
            &times;
          </span>
        </div>

        <div class="modal-internal-content">
          <CbeReview :cbe_id="cbeId" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CbeReview from "../../views/cbes/Review.vue";

export default {
  components: {
    CbeReview
  },
  data() {
    return {
      modalIsOpen: false
    };
  },
  props: {
    cbeId: Number
  }
};
</script>
