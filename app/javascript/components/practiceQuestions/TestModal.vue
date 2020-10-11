<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen" href="#myModal" class="btn btn-settings" data-backdrop="false" data-toggle="modal">Open Modal</button>
        <div id="myModal" class="modal2 fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                    <div class="modal2-header">
                        <button @click="modalIsOpen = !modalIsOpen" type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        <h4 class="modal2-title">Settings</h4>

                    </div>
                    <div class="modal2-body">
                        <h3>Lorem Ipsum</h3>
                        <p>Praesent non dictum dolor, vitae interdum erat. Nam quis consectetur mi. In consequat condimentum tortor, et lobortis est convallis ac. Quisque volutpat posuere dui, pellentesque vulputate dolor. Morbi dapibus orci eu est consectetur, sed pretium mauris laoreet. Pellentesque sodales ante non justo viverra, sit amet consectetur nisl vulputate.</p>
                    </div>
                    <div class="modal2-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                        <button id="loadpage" type="button" class="btn btn-primary">Save</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
    </div>
</template>

<script>

export default {
  components: {
  },
  data() {
    return {
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
    // Code that will run only after the entire view has been rendered
        $('#myModal').draggable();
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