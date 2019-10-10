<template>
  <div>
    <b-nav-text
      v-on:click="greet()"
      v-bind:class="{ flagged: pageFlag }"
      class="flag-icon"
    >Flag for Review</b-nav-text>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  data() {
    return {
      pageFlag: false
    };
  },
  props: {
    user_cbe_data: Object,
    route: Object,
  },
   watch: {
    route: {
      handler() {
        this.mapFlags()
      }
    }
  },
  created() {
    this.mapFlags();
  },
  methods: {
    greet: function() {
      let type = this.route.name;
      let id = this.route.params.id;

      this.user_cbe_data.exam_pages.forEach(item => {
        if (item.type == type && item.param == id) {
          item.flagged = !this.pageFlag;
          this.pageFlag = item.flagged;
        }
      });
    },
    mapFlags: function() {
      let type = this.route.name;
      let id = this.route.params.id;

      this.user_cbe_data.exam_pages.forEach(item => {
        if (item.type == type && item.param == id) {
          this.pageFlag = item.flagged;
        }
      });
    }
  }
};
</script>
