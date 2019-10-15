<template>
  <div>
    <b-nav-text
      v-on:click="markFlag()"
      v-bind:class="{ flagged: pageFlag }"
      class="flag-icon"
      >
        <div v-if="type != 'review'">Flag for Review</div>
      </b-nav-text
    >
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
    type: String,
    flagId: Number,
    user_cbe_data: Object,
  },
  watch: {
    flagId: {
      handler() {
        this.mapFlags();
      }
    },
    "user_cbe_data.exam_pages": {
      handler() {
        this.mapFlags();
      },
     deep: true
    }
  },
  created() {
    this.mapFlags();
  },
  methods: {
    markFlag: function() {
      let id = this.flagId;
      let type = this.type;

      this.user_cbe_data.exam_pages.forEach(item => {
        if (item.type == type && item.param == id) {
          item.flagged = !this.pageFlag;
          this.pageFlag = item.flagged;
        }
      });
    },
    mapFlags: function() {
      let id = this.flagId;
      let type = this.type;

      this.user_cbe_data.exam_pages.forEach(item => {
        if (item.type == type && item.param == id) {
          this.pageFlag = item.flagged;
        }
      });
    }
  }
};
</script>
