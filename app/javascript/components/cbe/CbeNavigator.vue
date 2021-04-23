<template>
  <div id="cbe-modals">
    <section
      class="components-sidebar-links navigation-icon"
      @click="show($event)"
    >
      Navigator
    </section>
    <VueModal
      :componentName="componentName"
      :componentType="componentType"
      :height="450"
      :width="350"
    >
    <div slot="body">
      <CbeReview :cbe_id="cbeId" />
    </div>
    </VueModal>
  </div>
</template>

<script>
import CbeReview from "../../views/cbes/Review.vue";
import eventBus from "./EventBus.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    CbeReview,
    VueModal
  },
  data() {
    return {
      modalIsOpen: false
    };
  },
  props: {
    cbeId: Number,
    componentType: {
      type: String,
      default: "nav",
    },
    componentName: {
      type: String,
      default: "Navigator",
    },
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  methods: {
    show (event) {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
    },
    hide (event) {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
  },
};
</script>
