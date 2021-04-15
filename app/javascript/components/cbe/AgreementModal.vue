<template>
  <VueWindow
    v-if="agreementModalIsOpen"
    :window-header="'Ready to begin?'"
    :window-is-open="true"
    @close="toggleResetModal()"
  >
    <p
      slot="body"
      v-html="cbe_data.agreement_content"
    />

    <div slot="footer">
      <b-button
        @click="acceptAgreement(true)"
      >
        Yes
      </b-button>
      <b-button
        @click="acceptAgreement(false)"
      >
        No
      </b-button>
    </div>
  </VueWindow>
</template>

<script>
import axios from 'axios';
import { mapGetters } from 'vuex';
import VueWindow from '../VueWindow.vue'

export default {
  components: {
    VueWindow,
  },
  props: {
    nextAction: Function,
  },
  data() {
    return {
      agreementModalIsOpen: true,
    };
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
    acceptAgreement(accepted) {
      const navLinks = document.getElementsByClassName('page-item');
      for (const link of navLinks) {
        link.style.display = 'block';
      }

      if (accepted) {
        this.userCbeData.user_agreement = true;
        this.updateAgreedOnUserLog();
      } else {
        window.location.href = `${this.userCbeData.cbe_id}`;
      }

      this.toggleResetModal();
    },
    updateAgreedOnUserLog() {
      console.log("Update CBE USER LOG");
      const data   = {};
      data.agreed  = this.userCbeData.user_agreement;

      axios
        .post(
          `/api/v1/cbes/${this.userCbeData.cbe_id}/users_log/${this.userCbeData.user_log_id}/user_agreement`,
          {
            id: this.userCbeData.user_log_id,
            cbe_user_log: data,
          }
        )
        .then((response) => {
          console.log("Cbe agreed by user.");
          this.nextAction();
          cbeStarted({cbeId: this.$parent.$parent.cbe_id, cbeName: this.$parent.$parent.$parent.cbe_name, productId: this.$parent.$parent.$parent.product_id, productName: this.$parent.$parent.$parent.product_name, courseId: this.$parent.$parent.$parent.course_id, courseName: this.$parent.$parent.$parent.course_name, examBodyId: this.$parent.$parent.$parent.exam_body_id, examBodyName: this.$parent.$parent.$parent.exam_body_name });
        })
        .catch((error) => {});
      console.log("CBE USER LOG CREATED");
    },
    toggleResetModal() {
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
