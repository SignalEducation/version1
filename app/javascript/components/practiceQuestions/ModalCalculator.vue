<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen" href="#calcModal" class="btn btn-settings calculator-icon-no-title" data-backdrop="false" data-toggle="modal"></button>
        <div id="calcModal" class="modal2-calc fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Calculator</h4>

                    </div>
                    <div class="modal2-body">
                      <Calculator />
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

import Calculator from '../Calculator.vue';

export default {
  components: {
    Calculator
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
        $('#calcModal').draggable();
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