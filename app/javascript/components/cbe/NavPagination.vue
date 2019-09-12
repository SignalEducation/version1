<template>
  <section class="overflow-auto">
    <b-pagination-nav
      :limit="0"
      :link-gen="linkGen"
      :number-of-pages="links.length"
      :hide-goto-end-buttons="true"
      prev-text="⏪ Previous"
      next-text="Next ⏩"
      use-router
    ></b-pagination-nav>
  </section>
</template>

<script>
export default {
  props: {
    links: Array
  },
  methods: {
    linkGen(pageNum, object) {
      return this.links[pageNum - 1];
    }
  }
};
</script>
