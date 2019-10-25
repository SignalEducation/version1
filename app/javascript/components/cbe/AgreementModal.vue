<template>
  <Modal v-if="agreementModalIsOpen" @close="toggleResetModal()">
    <h3 slot="header">
      Ready to begin?
    </h3>
    <p slot="body" v-html="cbe_data.agreement_content">
    </p>

    <div slot="footer">
      <b-button variant="success" @click="acceptAgreement(true)">
        Yes
      </b-button>
      <b-button variant="danger" @click="acceptAgreement(false)">
        No
      </b-button>
    </div>
  </Modal>
</template>

<script>
import axios from 'axios';
import { mapGetters } from 'vuex';
import Modal from '../../lib/Modal';

export default {
  components: {
    Modal,
  },
  data() {
    return {
      agreementModalIsOpen: true,
    };
  },
  props: {
    nextAction: Function,
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbe_data',
    }),
    ...mapGetters('userCbe', {
      userCbeData: 'userCbeData',
    }),
  },
  methods: {
    createUserLog: function() {
      axios
        .post(`/api/v1/cbes/${this.userCbeData.cbe_id}/users_log`, {
          cbe_user_log: this.formatedData(),
        })
        .then(response => {
          this.$store.dispatch('userCbe/recordUserLog', response.data.id);
          this.nextAction();
        })
        .catch(error => {});
    },
    formatedData: function() {
      let data = {};
      data.status = 'started';
      data.cbe_id = this.userCbeData.cbe_id;
      data.user_id = this.userCbeData.user_id;
      return data;
    },
    acceptAgreement: function(accepted) {
      if (accepted) {
        this.createUserLog();
      } else {
        window.location.href = `${this.userCbeData.cbe_id}`;
      }

      this.toggleResetModal();
    },
    toggleResetModal: function() {
      this.agreementModalIsOpen = !this.agreementModalIsOpen;
    },
  },
};
</script>

<style>
.modal-container {
  width: 600px !important;
}

.modal-mask .modal-wrapper .modal-container .modal-header h3 {
  color: #000000 !important;
  font-size: initial !important;
}
</style>
