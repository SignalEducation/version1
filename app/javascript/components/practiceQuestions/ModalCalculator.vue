<template>
    <div>
        <button @click="modalIsOpen = !modalIsOpen; updateZindex()" href="#calcModal" class="btn btn-settings calculator-icon-no-title" title="Calculator" data-backdrop="false" data-toggle="modal"></button>
        <div @click="updateZindex()" id="calcModal" class="modal2-calc fade" v-show="modalIsOpen">
            <div class="modal2-dialog">
                <div class="modal2-content">
                  <button @click="modalIsOpen = !modalIsOpen" type="button" class="close modal-close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <div class="modal2-header">
                        <h4 class="modal2-title">Calculator</h4>

                    </div>
                    <div class="modal2-body">
                      <div class="modal2-margin-top">
                        <Calculator />
                      </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

import Calculator from '../Calculator.vue';
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    Calculator,
    eventBus
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
        $('#calcModal').draggable();
    })
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value;
    },
    updateZindex() {
      eventBus.$emit('z-index-click', 'calcModal');
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