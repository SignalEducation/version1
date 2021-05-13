<template>
  <div class="non-resizable-modal">
    <section
      class="components-sidebar-links calculator-icon"
      @click="show($event)"
    >
      {{ componentName }}
    </section>

      <VueModal
        :componentName="componentName"
        :componentType="componentType"
        :mainColor="'#000032'"
        :textColor="'#ffffff'"
        :componentHeight="450"
        :componentWidth="550"
      >
      <div slot="body">
        <Calculator />
      </div>
      </VueModal>
  </div>
</template>

<script>
import Calculator from '../Calculator.vue';
import eventBus from "./EventBus.vue";
import VueModal from '../VueModal.vue';

export default {
  components: {
    Calculator,
    VueModal
  },
  props: {
    componentType: {
      type: String,
      default: "nav",
    },
    componentName: {
      type: String,
      default: "Calculator",
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
      eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
    },
    hide (event) {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
  },

};
</script>
