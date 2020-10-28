<template>
    <div class="submit-btn-modal">
        <button @click="modalIsOpen = !modalIsOpen;" href="#submitModal" class="btn btn-settings submit-btn-title" data-backdrop="false" data-toggle="modal"  data-target=".bs-example-modal-new"></button>
        <div class="modal fade bs-example-modal-new" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
            <div class="modal-header">
                <h4>Lesson Completed</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            </div>
              <div class="modal-body">
                <div class="body-message">
                  <p>You'll be redirected to the next lesson in 4 seconds...</p>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-submit-modal-outline" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-submit-modal" data-dismiss="modal">Next Step</button>
              </div>
            </div>
          </div>
        </div>
    </div>
</template>

<script>

export default {
  data() {
    return {
      modalIsOpen: false,
    };
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
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