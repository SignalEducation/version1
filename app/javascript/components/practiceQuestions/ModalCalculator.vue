<template>
  <div class="non-resizable-modal">
    <button @click="show()" class="cr-nav-link tool-btn">
      <div class="k-icon k-i-calculator"></div>
      Calculator
    </button>
    <VueModal
      :componentType="componentType"
      :componentName="componentName"
      :componentModal="componentModal"
      :mainColor="'#00b67B'"
      :textColor="'#ffffff'"
      :componentWidth="600"
    >
      <div slot="body">
        <div>
          <Calculator />
        </div>
      </div>
    </VueModal>
  </div>
</template>

<script>
import Calculator from "../Calculator.vue";
import eventBus from "../cbe/EventBus.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    Calculator,
    eventBus,
    VueModal,
  },
  props: {
    componentType: {
      type: String,
      default: "navbar",
    },
    componentName: {
      type: String,
      default: "Calculator",
    },
    componentModal: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      modalIsOpen: false,
    };
  },
  created() {
    eventBus.$on("close-modal", (status) => {
      this.modalIsOpen = status;
    });
  },
  mounted() {
    this.$nextTick(function() {
      $("#calcModal").draggable();
    });
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    show() {
      this.$modal.show(
        "modal-" + this.componentType + "-" + this.componentName
      );
      $(".components-sidebar .components div").removeClass("active-modal");
      eventBus.$emit(
        "update-modal-z-index",
        `modal-${this.componentType}-${this.componentName}`
      );
    },
    hide() {
      $(".latent-modal").removeClass("active-modal");
      this.$modal.hide(
        "modal-" + this.componentType + "-" + this.componentName
      );
    },
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
