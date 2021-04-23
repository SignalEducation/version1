<template>
  <div>
    <section
      class="components-sidebar-links calculator-icon"
      @click="show($event)"
    >
      Calculator
    </section>

      <VueModal
        :componentName="componentName"
        :componentType="componentType"
        :mainColor="'#000032'"
        :textColor="'#ffffff'"
        :height="450"
        :width="350"
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
      default: "",
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
    },
    hide (event) {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
    },
  },

};
</script>
