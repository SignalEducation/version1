<template>
  <section>
    <div
        v-bind:id="'introductions-' + page.id"
        v-for="page in cbe_data.introduction_pages"
        v-if="page.id == id"
        :key="page.id"
      >
      <div class="intructions-counter">
        Introductions {{ `(${page.id} of ${cbe_data.introduction_pages.length})` }}
      </div>

      <div class="content">
        <p v-html="page.content" />
      </div>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  props: {
    id: String
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbeData'
    })
  }
}
</script>

