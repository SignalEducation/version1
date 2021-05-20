<template>
    <div class="non-resizable-modal">
        <button @click="show()" class="btn btn-settings scratch-pad-no-title components-sidebar-links" title="Scratch Pad"></button>
        <VueModal
          :componentType="componentType"
          :componentName="componentName"
          :componentModal="componentModal"
          :mainColor="'rgba(24, 24, 66, 0.95)'"
          :textColor="'#ffffff'"
          :componentHeight="475"
        >
        <div slot="body">
          <div>
            <editor
              :api-key="apiKey"
              :init="{
                height: 335,
                branding: false,
                menubar: false,
                statusbar: false,
                resize: false,
                toolbar: ['cut copy paste undo redo']
              }"
            />
          </div>
        </div>
      </VueModal>
    </div>
</template>

<script>

import Editor from "@tinymce/tinymce-vue";
import eventBus from "../cbe/EventBus.vue";
import VueModal from "../VueModal.vue";

export default {
  components: {
    Editor,
    eventBus,
    VueModal
  },
  props: {
    componentType: {
      type: String,
      default: "navbar",
    },
    componentName: {
      type: String,
      default: "Scratch Pad",
    },
    componentModal: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      apiKey: "6lr2e49pkvekjoocwhblfmatskmhek3h3ae8f4cbpfw3u3vw",
      modalIsOpen: false,
    };
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  mounted() {
    this.$nextTick(function () {
        $('#scratchPadModal').draggable();
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    show () {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
      eventBus.$emit("update-modal-z-index", `modal-${this.componentType}-${this.componentName}`);
    },
    hide () {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
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