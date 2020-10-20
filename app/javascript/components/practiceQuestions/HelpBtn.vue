<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex()" href="#helpModal" class="btn btn-settings help-btn-title" title="Calculator" data-backdrop="false" data-toggle="modal"></button>
        <div @click="updateZindex()" id="helpModal" class="modal2 modal-help fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Help</h4>

                    </div>
                    <div class="modal2-body">
                      <PDFViewer :active=true :file-url="this.tempPDFfile" />
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
      tempPDFfile: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    };
  },
  mounted() {
    this.$nextTick(function () {
        $('#helpModal').draggable();
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit('z-index-click', 'helpModal');
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