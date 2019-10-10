<template>
  <header class="header fixed-top" id="cbe-nav-header">
    <b-navbar toggleable="lg" type="dark">
      <router-link
        to="/"
        v-slot="{ href, route, navigate, isActive, isExactActive }"
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
      class="nav nav-underline bg-cbe-gray"
      v-if="showNavOptions($route.name)"
    >
      <b-navbar-nav>
        <b-nav-text class="symbols-icon">Symbol</b-nav-text>
        <b-nav-text class="calculator-icon">Calculator</b-nav-text>
        <CbeScratchPad :user_cbe_data="user_cbe_data" />
      </b-navbar-nav>
      <b-navbar-nav align="right">
        <CbeFlagToReview :user_cbe_data="user_cbe_data" :route="$route" />
      </b-navbar-nav>
    </b-navbar>
  </header>
</template>

<script>
import CbeFlagToReview from "../CbeFlagToReview";
import CbeNavPages from "../CbeNavPages";
import CbeScratchPad from "../CbeScratchPad";

export default {
  components: {
    CbeFlagToReview,
    CbeNavPages,
    CbeScratchPad
  },
  props: {
    logo: String,
    title: String,
    user_cbe_data: Object
  },
  methods: {
    showNavOptions: function(page) {
      let permitted_pages = ["sections", "questions"];

      return permitted_pages.includes(page);
    }
  }
};
</script>
