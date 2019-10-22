<template>
  <div class="btn-row">
    <div class="btn-group">
      <button
        type="button"
        :class="'btn btn-default reset'"
        @click="showResetModal"
      />
      <Modal
        v-if="resetModalIsOpen"
        @close="toggleResetModal()"
      >
        <h3 slot="header">
          Reset Spreadsheet
        </h3>
        <p slot="body">
          Resetting the spreadsheet will revert any changes you have made so far.
          Are you sure you want to reset the spreadsheet?
        </p>
        <div slot="footer">
          <b-button
            variant="outline-success"
            @click="toggleResetModal()"
          >
            Cancel
          </b-button>
          <b-button
            variant="outline-danger"
            @click="resetSpreadsheet()"
          >
            Reset Sheet
          </b-button>
        </div>
      </Modal>
      <button
        type="button"
        :class="['btn btn-default cut']"
        @click="cut()"
      />
      <button
        type="button"
        :class="['btn btn-default copy']"
        @click="copy()"
      />
      <button
        type="button"
        :class="['btn btn-default paste']"
        @click="paste()"
      />
      <button
        type="button"
        :class="['btn btn-default undo']"
        :disabled="!canUndo"
        @click="undo"
      />
      <button
        type="button"
        :class="['btn btn-default redo']"
        :disabled="!canRedo"
        @click="redo"
      />
    </div>
  </div>
</template>

<script>
  import Modal from '../../../lib/Modal';
  import '../SpreadsheetEditor.scss';

  export default {
    components: {
      Modal,
    },
    props: {
      canUndo: {
        type: Boolean,
        default: false,
      },
      canRedo: {
        type: Boolean,
        default: false,
      },
      cut: {
        type: Function,
        default: () => 1,
      },
      copy: {
        type: Function,
        default: () => 1,
      },
      paste: {
        type: Function,
        default: () => 1,
      },
      undo: {
        type: Function,
        default: () => 1,
      },
      redo: {
        type: Function,
        default: () => 1,
      },
    },
    data() {
      return {
        resetModalIsOpen: false,
      };
    },
    methods: {
      resetSpreadsheet() {
        this.resetModalIsOpen = false;
        this.$emit('reset-spreadsheet');
      },
      showResetModal () {
        this.resetModalIsOpen = true;
      },
      toggleResetModal () {
        this.resetModalIsOpen = !this.resetModalIsOpen;
      },
    }
  }
</script>
