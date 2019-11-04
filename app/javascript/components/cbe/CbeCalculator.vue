<template>
  <div class="cbe-calculator" id="cbe-calculator" v-show="modalIsOpen" >
    <Modal @close="toggleResetModal()">
      <h3 slot="header">
        Calculator
      </h3>
      <p slot="body">
        <Calculator />
      </p>
    </Modal>
  </div>
</template>

<script>
import Calculator from '../Calculator.vue';
import Modal from '../../lib/Modal/index.vue';

export default {
  components: {
    Calculator,
    Modal,
  },
  data() {
    return {
      modalIsOpen: true,
    };
  },
  methods: {
    toggleResetModal() {
      this.modalIsOpen = !this.modalIsOpen;
    },
  },
};
</script>

<style>
.cbe-calculator .modal-container {
  width: 560px !important;
  height: 400px;
}

.cbe-calculator .modal-mask .modal-wrapper .modal-container .modal-header {
  display: block;
  height: 172px;
}

.cbe-calculator .modal-mask .modal-wrapper .modal-container .modal-header h3 {
  color: #000000 !important;
  font-size: initial !important;
}
</style>
