<template>
  <section>
    <!-- TODO(Giordano), Find a way to pass just the specific page object instead check in a v-for. -->
   <div
      class="introduction_pages"
      v-bind:id="'introduction-page-' + page.id"
      v-for="page in cbe_data.introduction_pages"
      v-if="page.id == id"
      :key="page.id"
    >
      <div class="header">
        <h1>Introduction - {{ page.sorting_order }}</h1>
        <h3>{{ page.title }}</h3>
      </div>

      <div class="content">
          <p>{{ page.content }}</p>
      </div>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  props: {
    id: {
      // required: true,
      // type: Number
    }
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbeData'
    })
  }
}
</script>

