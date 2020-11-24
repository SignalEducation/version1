<template>
    <div>
      <button @click="modalsStatus(false)" href="#closeAllModals" class="btn btn-settings solution-btn-title" data-backdrop="false" data-toggle="modal">Close All</button>
    </div>
</template>

<script>
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus,
  },
  methods: {
    modalsStatus(status) {
      eventBus.$emit("close-modal", false);
    },
  },
};
</script>
