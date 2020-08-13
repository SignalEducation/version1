<template>
  <div>
    <section class="exhibits-sidebar-links requirement-icon" @click="showModal = !showModal">
      {{ `${requirementName} (${requirementScore} marks)` }}
    </section>

    <hsc-window-style-white>
      <hsc-window
        :title="requirementName"
        :closeButton="true"
        :isOpen.sync="showModal"
        :width="700"
        positionHint="center" >
        <span v-html="requirementContent"></span>
      </hsc-window>

    </hsc-window-style-white>
  </div>
</template>

<script>
import VueWindow from '../VueWindow.vue'

export default {
  components: {
    VueWindow,
  },
  props: {
    requirementScore: {
      type: Number,
      default: null,
    },
    requirementName: {
      type: String,
      default: "",
    },
    requirementContent: {
      type: String,
      default: "",
    },
    requirementModal: {
      type: Boolean,
      default:  false
    },
  },
  data() {
    return {
      showModal: this.requirementModal,
    }
  }
};
</script>
