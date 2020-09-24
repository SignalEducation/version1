<template>
  <div id="cbe-modals">
    <b-nav-text
      class="scratch-pad-icon"
      @click="modalIsOpen = !modalIsOpen"
    >
      Scratch Pad
    </b-nav-text>

    <VueWindow
      v-if="modalIsOpen"
      :window-header="'Scratch Pad'"
      :window-width="700"
      :window-height="300"
      :window-is-open="modalIsOpen"
      @updateWindowClose="handleChange"
    >
      <div
        slot="body"
      >
        <editor
          v-model="userCbeData.scratch_pad"
          :api-key="apiKey"
          :init="{
            branding: false,
            menubar: false,
            statusbar: false,
            resize: false,
            toolbar: ['cut copy paste undo redo']
          }"
        />
      </div>
    </VueWindow>
  </div>
</template>

<script>

import Editor from "@tinymce/tinymce-vue";
import eventBus from "./EventBus.vue";
import VueWindow from '../VueWindow.vue'

export default {
  components: {
    Editor,
    VueWindow,
  },
  props: {
    userCbeData: Object,
  },
  data() {
    return {
      apiKey: "6lr2e49pkvekjoocwhblfmatskmhek3h3ae8f4cbpfw3u3vw",
      modalIsOpen: false
    };
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value
    }
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
