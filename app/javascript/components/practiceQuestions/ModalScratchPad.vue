<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen" href="#scratchPadModal" class="btn btn-settings scratch-pad-no-title" title="Scratch Pad" data-backdrop="false" data-toggle="modal"></button>
        <div id="scratchPadModal" class="modal2 fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Scratch Pad</h4>

                    </div>
                    <div class="modal2-body">
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
                </div>
            </div>
        </div>
    </div>
</template>

<script>

import Editor from "@tinymce/tinymce-vue";

export default {
  components: {
    Editor,
  },
  data() {
    return {
      apiKey: "6lr2e49pkvekjoocwhblfmatskmhek3h3ae8f4cbpfw3u3vw",
      modalIsOpen: false,
    };
  },
  mounted() {
    this.$nextTick(function () {
        $('#scratchPadModal').draggable();
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
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