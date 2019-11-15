<template>
  <div id="cbe-modals">
    <b-nav-text
      class="help-icon"
      @click="modalIsOpen = !modalIsOpen"
    >
      Help
    </b-nav-text>

    <div ref="resourcesModal" class="modal" v-show="modalIsOpen">
      <div class="modal-content resources-modal">
        <div class="modal-header bg-cbe-gray">
          <span class="title help-icon">
            Help
          </span>

          <span class="close" @click="modalIsOpen = !modalIsOpen">
            &times;
          </span>
        </div>

        <div class="modal-internal-content">
          <CbeResourceTabs
            :files="fileArray"
            :active="modalIsOpen"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CbeResourceTabs from "./CbeResourceTabs.vue";

export default {
  components: {
    CbeResourceTabs,
  },
  props: {
    cbe_data: {
      type: Object,
      default: () => ({}),
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
};
</script>
