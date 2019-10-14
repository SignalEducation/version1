<template>
  <b-navbar-nav class="ml-auto">
    <b-nav-text class="progress-count-icon-white">
      {{ pageNumber }} of {{ pageTotal }}
    </b-nav-text>
  </b-navbar-nav>
</template>

<script>
export default {
  data() {
    return {
      pageNumber: null,
      pageTotal: null
    };
  },
  props: {
    userCbeData: Object,
    pageId: {},
    pageName: String
  },
  created() {
    this.mapPages();
  },
  watch: {
    pageId: {
      handler() {
        this.mapPages();
      }
    }
  },
  methods: {
    mapPages: function() {
      let id = this.pageId;
      let type = this.pageName;
      let total = 0;

      this.userCbeData.exam_pages.forEach(item => {
        if (item.type == type) {
          total++;
          if (item.param == id) {
            this.pageNumber = item.page;
          }
        }
      });

      this.pageTotal = total;
    }
  }
};
</script>
