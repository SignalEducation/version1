<template>
  <header id="cbe-nav-header" class="header fixed-top" >
    <b-navbar toggleable="lg" type="dark">
      <router-link
        v-slot="{ href, route, navigate, isActive, isExactActive }"
        to="/"
      >
        <b-navbar-brand :href="href" @click="navigate">{{
          logo
        }}</b-navbar-brand>
      </router-link>

      <CbeNavPages
        v-if="$route.name == 'questions'"
        :userCbeData="user_cbe_data"
        :pageId="$route.params.id"
        :pageName="$route.name"
      />
    </b-navbar>

    <b-navbar
      v-if="showNavOptions(['sections', 'questions'])"
      class="nav nav-underline bg-cbe-gray"
    >
      <b-navbar-nav>
        <!-- <b-nav-text class="symbols-icon">Symbol</b-nav-text> -->
        <b-nav-text v-if="showNavOptions(['questions'])"
                    @click="toggleResetModal()" class="calculator-icon">Calculator</b-nav-text>

        <CbeScratchPad
          v-if="showNavOptions(['questions'])"
          :user_cbe_data="user_cbe_data"
        />
      </b-navbar-nav>
      <b-navbar-nav align="right">
        <CbeFlagToReview
          :user_cbe_data="user_cbe_data"
          :type="$route.name"
          :flag-id="$route.params.id"
        />
      </b-navbar-nav>
    </b-navbar>
  </header>
</template>

<script>
import CbeFlagToReview from './CbeFlagToReview';
import CbeNavPages from './CbeNavPages';
import CbeScratchPad from './CbeScratchPad';

export default {
  components: {
    CbeFlagToReview,
    CbeNavPages,
    CbeScratchPad,
  },
  props: {
    logo: String,
    title: String,
    user_cbe_data: Object,
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
