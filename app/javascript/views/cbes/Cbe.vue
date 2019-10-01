<template>
  <section>
    <p v-html="cbe_data.agreement_content" />
  </section>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbe_data',
    }),
  },
};
</script>
