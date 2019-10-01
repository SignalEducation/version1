<template>
  <section class="cbe-section">
    <NavBar v-bind:logo="'CBE'" v-bind:title="cbe_data.title" />

    <div class="cbe-content panel panel-default">
      <router-view :id="$route.path" />
    </div>

    <footer class="cbe-footer">
      <div class="container">
        <NavPagination v-bind:link_data="cbe_data" />
      </div>
    </footer>
  </section>
</template>

<script>
import NavBar from "./NavBar";
import NavPagination from "./NavPagination";
import { mapGetters } from "vuex";

export default {
  data() {
    return {
      cbeId: this.$parent.cbe_id,
      userId: this.$parent.user_id
    };
  },
  mounted() {
    this.$store.dispatch("cbe/getCbe", this.cbeId);
  },
  computed: {
    ...mapGetters("cbe", {
      cbe_data: "cbeData"
    }),
    ...mapGetters("userCbe", {
      user_cbe_data: "userCbeData"
    })
  },
  watch: {
    cbe_data: {
      handler() {
        this.$store.dispatch("userCbe/startUserCbeData", {
          cbe_id: this.cbeId,
          user_id: this.userId,
          cbe_data: this.cbe_data
        });
      }
    }
  },
  components: {
    NavBar,
    NavPagination
  }
};
</script>
