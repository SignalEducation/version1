<template>
  <section style="padding: 25px;">
    <div
      class="sections"
      v-bind:id="'section-' + section.sorting_order"
      v-for="section in cbe_data.sections"
      v-if="section.id == id"
      :key="section.id"
    >
      <div class="content">
        <div v-html="section.content" />
      </div>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  props: {
    id: Number,
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbe_data',
    }),
  },
};
</script>
