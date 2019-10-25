<template>
  <section style="padding: 25px;">
    <div
        v-bind:id="'introductions-' + page.id"
        v-for="page in cbe_data.introduction_pages"
        v-if="page.id == id"
        :key="page.id"
      >

      <div class="content">
        <div v-html="page.content" />
      </div>
    </div>

    <AgreementModal v-if="agreementModalIsOpen" :nextAction="this.nextAction" />
  </section>
</template>

<script>
import AgreementModal from '../../components/cbe/AgreementModal';
import { mapGetters } from 'vuex'

export default {
  components: {
    AgreementModal,
  },
  data() {
    return {
      agreementModalIsOpen: false,
      nextAction: null,
    };
  },
  props: {
    id: {}
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
  },
};
</script>
