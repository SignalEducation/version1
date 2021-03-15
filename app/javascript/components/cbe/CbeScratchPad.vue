<template>
  <div>
    <section
      class="components-sidebar-links scratch-pad-icon"
      @click="show($event)"
    >
      Scratch Pad
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
    </VueModal>
  </div>
</template>

<script>

import Editor from "@tinymce/tinymce-vue";
import eventBus from "./EventBus.vue";
import VueModal from '../VueModal.vue'

export default {
  components: {
    Editor,
    VueModal,
  },
  props: {
    userCbeData: Object,
    componentType: {
      type: String,
      default: "nav",
    },
    componentName: {
      type: String,
      default: "Scratch Pad",
    },
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
