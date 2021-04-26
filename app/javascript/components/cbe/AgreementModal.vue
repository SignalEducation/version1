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
    createUserLog() {
      axios
        .post(`/api/v1/cbes/${this.userCbeData.cbe_id}/users_log`, {
          cbe_user_log: this.formatedData(),
        })
        .then(response => {
          this.$store.dispatch('userCbe/recordUserLog', response.data);
          this.nextAction();
        })
        .catch(error => {});
    },
    formatedData() {
      const data = {};
      data.cbe_id = this.userCbeData.cbe_id;
      data.user_id = this.userCbeData.user_id;
      data.exercise_id = this.userCbeData.exercise_id;

      return data;
    },
    acceptAgreement(accepted) {
      const navLinks = document.getElementsByClassName('page-item');
      for (const link of navLinks) {
        link.style.display = 'block';
      }

      if (accepted) {
        this.createUserLog();
        cbeStarted({preferredExamBodyId: this.$parent.preferred_exam_body_id, preferredExamBody: this.$parent.preferred_exam_body_name, banner: 'false', onboarding: this.$parent.onboarding, cbeId: this.$parent.$parent.cbe_id, cbeName: this.$parent.$parent.$parent.cbe_name, productId: this.$parent.$parent.$parent.product_id, productName: this.$parent.$parent.$parent.product_name, courseId: this.$parent.$parent.$parent.course_id, courseName: this.$parent.$parent.$parent.course_name, examBodyId: this.$parent.$parent.$parent.exam_body_id, examBodyName: this.$parent.$parent.$parent.exam_body_name });
      } else {
        window.location.href = `${this.userCbeData.cbe_id}`;
      }

      this.toggleResetModal();
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
