<template>
  <div id="cbe-modals">
    <section
      class="components-sidebar-links help-icon"
      @click="show($event)"
    >
      Help
    </section>

    <VueModal
      :componentName="componentName"
      :componentType="componentType"
      :componentHeight="550"
      :componentWidth="1100"
    >
    <div slot="body">
      <CbeResourceTabs
        :files="fileArray"
        :active="true"
      />
    </div>
    </VueModal>
  </div>
</template>

<script>
import CbeResourceTabs from "./CbeResourceTabs.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    CbeResourceTabs,
    VueModal
  },
  props: {
    cbe_data: {
      type: Object,
      default: () => ({}),
    },
    componentType: {
      type: String,
      default: "nav",
    },
    componentName: {
      type: String,
      default: "Help",
    },
  },
  data() {
    return {
      modalIsOpen: false,
    };
  },
  computed: {
    fileArray: function() {
      if (!this.cbe_data.resources) {
        return [];
      }
      return this.cbe_data.resources.map((resource) => ({id: resource.id, sorting_order: resource.sorting_order, title: resource.name, url: resource.file.url}))
    },
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
