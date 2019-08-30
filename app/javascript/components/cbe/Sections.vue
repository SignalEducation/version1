<template>
  <section>
    <!-- TODO(Giordano), Find a way to pass just the specific page object instead check in a v-for. -->
    <div
      class="sections"
      v-bind:id="'section-' + section.sorting_order"
      v-for="section in cbe_data.sections"
      v-if="section.id == id"
      :key="section.id"
    >
      <div class="header">
        <h1>Section - {{ section.sorting_order }}</h1>
        <h3>Score - {{ section.score }}</h3>
        <h3>Kind - {{ section.kind }}</h3>
      </div>

      <div class="content">
        <p>{{ section.content }}</p>
      </div>
    </div>
  </section>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  props: {
    id: {
      // required: true,
      // type: Number
    }
  },
  computed: {
    ...mapGetters("cbe", {
      cbe_data: "cbeData"
    })
  }
};
</script>

