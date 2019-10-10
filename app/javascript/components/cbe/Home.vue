<template>
  <section class="cbe-section" id="student-cbe">
    <NavBar :logo="cbe_data.name" :title="cbe_data.name" :user_cbe_data="user_cbe_data" />

    <div class="cbe-content">
      <router-view :id="$route.path" />
    </div>

    <div id="cbe-footer">
      <footer>
        <b-navbar class="nav nav-underline bg-cbe-gray">
          <b-navbar-nav>
            <b-nav-text class="help-icon">Help</b-nav-text>
          </b-navbar-nav>
          <b-navbar-nav>
            <NavPagination v-bind:link_data="cbe_data" />
          </b-navbar-nav>
        </b-navbar>
      </footer>
    </div>
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
