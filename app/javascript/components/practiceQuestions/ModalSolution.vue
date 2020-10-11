<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen" href="#solutionModal" class="btn btn-settings solution-btn-title" data-backdrop="false" data-toggle="modal">Solution</button>
        <div id="solutionModal" class="modal2-calc fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Solution</h4>

                    </div>
                    <div class="modal2-body">
                        <h3>{{solutionTitle}}</h3>
                        <p>{{solutionDescription}}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

export default {
  components: {

  },
  props: {
  	solutionTitle: {
      type: String,
    },
  	solutionDescription: {
      type: String,
  	},
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
        $('#solutionModal').draggable();
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