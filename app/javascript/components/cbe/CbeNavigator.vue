<template>
  <div id="cbe-modals" class="cbe-navigator-modal">
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
    <div v-show="activeOverlay" class="ls-overlay" @click="hide()"></div>
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
      activeOverlay: false
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
    eventBus.$on("close-active-overlay",(status)=>{
      this.activeOverlay = status;
    })
  },
  methods: {
    show (event) {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      this.activeOverlay = true;
      $('.components-sidebar .components div').removeClass('active-modal');
      eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
    },
    hide (event) {
      this.activeOverlay = false;
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
  },
};
</script>
