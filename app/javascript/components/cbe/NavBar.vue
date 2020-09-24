<template>
  <header id="cbe-nav-header" class="header fixed-top">
    <b-navbar toggleable="lg" type="dark">
      <router-link
        v-slot="{ href, route, navigate, isActive, isExactActive }"
        to="/"
      >
        <b-navbar-brand
          :href="href"
          @click.native.prevent="confirmNavigate(href)"
          >{{ logo }}</b-navbar-brand
        >
      </router-link>

      <CbeNavPages
        v-if="$route.name == 'questions'"
        :user-cbe-data="userCbeData"
        :page-id="$route.params.id"
        :page-name="$route.name"
      />
    </b-navbar>

    <b-navbar
      v-show="showNavOptions(['sections', 'scenarios', 'questions'])"
      class="nav nav-underline bg-cbe-gray"
    >
      <b-navbar-nav>
        <!-- <b-nav-text class="symbols-icon">Symbol</b-nav-text> -->
        <CbeCalculator
          v-show="showNavOptions(['scenarios', 'questions'])"
          :modal-status="calcModalStatus"
          @update-close-all="calcModalStatus = $event"
        />

        <CbeScratchPad
          v-if="showNavOptions(['scenarios', 'questions'])"
          :user-cbe-data="userCbeData"
          :modal-status="scraModalStatus"
          @update-close-all="scraModalStatus = $event"
        />
      </b-navbar-nav>

      <b-navbar-nav align="right">
        <b-nav-text
          v-if="showNavOptions(['scenarios', 'questions'])"
          class="close-all-icon"
          @click="modalsStatus(false)">
            Close All
        </b-nav-text>

        <CbeFlagToReview
          v-if="showNavOptions(['sections', 'scenarios', 'questions'])"
          :user_cbe_data="userCbeData"
          :type="$route.name"
          :flag-id="Number($route.params.id)"
        />
      </b-navbar-nav>
    </b-navbar>
  </header>
</template>

<script>
import CbeCalculator from "./CbeCalculator.vue";
import CbeFlagToReview from "./CbeFlagToReview.vue";
import CbeNavPages from "./CbeNavPages.vue";
import CbeScratchPad from "./CbeScratchPad.vue";

export default {
  components: {
    CbeCalculator,
    CbeFlagToReview,
    CbeNavPages,
    CbeScratchPad,
  },
  props: {
    logo: String,
    title: String,
    userCbeData: Object,
    calcModalStatus: {
      type: Boolean,
      default: null,
    },
    scraModalStatus: {
      type: Boolean,
      default: null,
    },
  },
  methods: {
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    toggleResetModal() {
      document.getElementById("cbe-calculator").style.display = "block";
    },
    modalsStatus(status) {
      this.$emit("update-close-all", status);
      this.calcModalStatus = status
      this.scraModalStatus = status
    },
    confirmNavigate(url) {
      if (confirm("Are you sure do you wanna leave?")) {
        window.location.href = url;
      } else {
        return false;
      }
    },
  },
};
</script>
