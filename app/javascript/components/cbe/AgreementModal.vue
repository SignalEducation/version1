<template>
<div class="non-resizable-modal">
  <VueModal
      :componentType="componentType"
      :componentName="componentName"
      :window-is-open="true"
      :componentModal="true"
      :componentHeight="270"
      :componentWidth="500"
      :mainColor="'transparent'"
    >
    <div slot="body">
      <p v-html="cbe_data.agreement_content" />
      <div class="agreement-modal-btns">
        <b-button @click="acceptAgreement(true)">
          Yes
        </b-button>
        <b-button @click="acceptAgreement(false)">
          No
        </b-button>
      </div>
    </div>
  </VueModal>
  </div>
</template>

<script>
import axios from 'axios';
import { mapGetters } from 'vuex';
import VueModal from '../VueModal.vue';
import eventBus from '../cbe/EventBus.vue';

export default {
  components: {
    VueModal,
    eventBus
  },
  props: {
    nextAction: Function,
    componentType: {
      type: String,
      default: "nav",
    },
    componentName: {
      type: String,
      default: "Ready to Begin?",
    },
  },
  data() {
    return {
      agreementModalIsOpen: true,
    };
  },
  mounted() {
    this.show();
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
          this.nextAction();
          cbeStarted({cbeId: this.$parent.$parent.cbe_id, cbeName: this.$parent.$parent.$parent.cbe_name, productId: this.$parent.$parent.$parent.product_id, productName: this.$parent.$parent.$parent.product_name, courseId: this.$parent.$parent.$parent.course_id, courseName: this.$parent.$parent.$parent.course_name, examBodyId: this.$parent.$parent.$parent.exam_body_id, examBodyName: this.$parent.$parent.$parent.exam_body_name });
        })
        .catch((error) => {});
    },
    toggleResetModal() {
      this.agreementModalIsOpen = !this.agreementModalIsOpen;
    },
    show () {
      this.$modal.show("modal-"+this.componentType+"-"+this.componentName);
      $('.components-sidebar .components div').removeClass('active-modal');
    },
    hide () {
      $('.latent-modal').removeClass('active-modal');
      this.$modal.hide("modal-"+this.componentType+"-"+this.componentName);
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
