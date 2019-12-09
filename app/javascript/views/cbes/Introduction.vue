<template>
  <section style="padding: 25px;">
    <div
      v-for="page in cbe_data.introduction_pages"
      :id="'introductions-' + page.id"
      v-if="page.id == id"
      :key="page.id"
    >
      <div class="content">
        <div v-html="page.content" />
      </div>
    </div>

    <AgreementModal
      v-if="agreementModalIsOpen"
      :next-action="nextAction"
    />
  </section>
</template>

<script>
import { mapGetters } from 'vuex'
import AgreementModal from '../../components/cbe/AgreementModal.vue';

export default {
  components: {
    AgreementModal,
  },
  props: {
    id: {}
  },
  data() {
    return {
      agreementModalIsOpen: false,
      nextAction: null,
    };
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbe_data',
    }),
    ...mapGetters('userCbe', {
      user_cbe_data: 'userCbeData',
    }),
  },
  mounted() {
    this.showLoading();
  },
  beforeUpdate() {
    this.closeLoading();
  },
  beforeRouteLeave (to, from, next) {
    this.agreementModalIsOpen = true
    this.nextAction = next;

    const navLinks = document.getElementsByClassName('page-item');
    for (const link of navLinks) {
      link.style.display = 'none';
    }
  },
  methods: {
    showLoading() {
      this.loader = this.$loading.show({
        loader: 'dots',
        color: '#00b67B',
        container: this.fullPage ? null : this.$refs.formContainer,
        canCancel: true,
        onCancel: this.onCancel,
      });
    },
    closeLoading() {
      this.loader.hide();
    },
  },
};
</script>
