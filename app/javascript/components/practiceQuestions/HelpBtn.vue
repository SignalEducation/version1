<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex(); resetModalDims()" href="#helpModal" class="btn btn-settings help-btn-title" title="Help" data-backdrop="false" data-toggle="modal"></button>
        <div @click="updateZindex()" id="helpModal" class="modal2-help modal-help fade resizemove" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div id="helpheader" class="modal2-header-lg">
                        <h4 class="modal2-title">Help</h4>
                    </div>
                    <div class="modal2-body">
                      <div>
                        <PDFViewer :active=true :file-url="helpPdf" />
                      </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

import PDFViewer from "../../lib/PDFViewer/index.vue";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    PDFViewer,
    eventBus
  },
  data() {
    return {
      modalIsOpen: false,
    };
  },
  props: {
    helpPdf: String
  },
  created() {
    eventBus.$on("close-modal",(status)=>{
      this.modalIsOpen = status;
    })
  },
  mounted() {
    $('#helpModal').draggable({ handle:'.modal2-header-lg'});
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit('z-index-click', 'helpModal');
    },
    resetModalDims() {
      $('#helpModal').css('width', '60em');
      $('#helpModal').css('height', '37em');
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