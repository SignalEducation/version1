<template>
  <section style="padding: 25px;">
    <div
      :id="'introductions-' + page.id"
      v-for="page in cbe_data.introduction_pages"
      v-if="page.id == id"
      :key="page.id"
    >
<div class="content">
        <div v-html="page.content" />
      </div>
    </div>

    <AgreementModal v-if="agreementModalIsOpen"
:next-action="this.nextAction" />
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
  beforeRouteLeave (to, from, next) {
    this.agreementModalIsOpen = true
    this.nextAction = next;

    const navLinks = document.getElementsByClassName('page-item');
    for (const link of navLinks) {
      link.style.display = 'none';
    }
  }
};
</script>
