<template>
  <header
    id="cbe-nav-header"
    class="header fixed-top"
  >
    <b-navbar
      toggleable="lg"
      type="dark"
    >
      <router-link
        v-slot="{ href, route, navigate, isActive, isExactActive }"
        to="/"
      >
        <b-navbar-brand
          :href="href"
          @click="navigate"
        >
          {{
            logo
          }}
        </b-navbar-brand>
      </router-link>

      <CbeNavPages
        v-if="$route.name == 'questions'"
        :user-cbe-data="userCbeData"
        :page-id="$route.params.id"
        :page-name="$route.name"
      />
    </b-navbar>

    <b-navbar
      v-if="showNavOptions(['sections', 'questions'])"
      class="nav nav-underline bg-cbe-gray"
    >
      <b-navbar-nav>
        <!-- <b-nav-text class="symbols-icon">Symbol</b-nav-text> -->
        <CbeCalculator
          v-if="showNavOptions(['questions'])"
        />

        <CbeScratchPad
          v-if="showNavOptions(['questions'])"
          :user-cbe-data="userCbeData"
        />
      </b-navbar-nav>
      <b-navbar-nav align="right">
        <CbeFlagToReview
          :user_cbe_data="userCbeData"
          :type="$route.name"
          :flag-id="$route.params.id"
        />
      </b-navbar-nav>
    </b-navbar>
  </header>
</template>

<script>
import CbeCalculator from './CbeCalculator.vue';
import CbeFlagToReview from './CbeFlagToReview.vue';
import CbeNavPages from './CbeNavPages.vue';
import CbeScratchPad from './CbeScratchPad.vue';

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
  },
  methods: {
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    },
    toggleResetModal() {
      document.getElementById('cbe-calculator').style.display = 'block'
    },
  },
};
</script>
