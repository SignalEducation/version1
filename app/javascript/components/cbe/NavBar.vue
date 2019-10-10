<template>
  <header class="header fixed-top" id="cbe-nav-header">
    <b-navbar toggleable="lg" type="dark">
      <router-link to="/" v-slot="{ href, route, navigate, isActive, isExactActive }">
        <b-navbar-brand :href="href" @click="navigate">{{ logo }}</b-navbar-brand>
      </router-link>

      <b-navbar-nav class="ml-auto">
        <!-- TODO, update with pagination -->
        <b-nav-text class="progress-count-icon-white">1 of 23</b-nav-text>
      </b-navbar-nav>
    </b-navbar>

    <b-navbar class="nav nav-underline bg-cbe-gray">
      <b-navbar-nav>
        <b-nav-text class="symbols-icon">Symbol</b-nav-text>
        <b-nav-text class="calculator-icon">Calculator</b-nav-text>
        <b-nav-text class="scratch-pad-icon">Scratch Pad</b-nav-text>
      </b-navbar-nav>
      <b-navbar-nav align="right">
        <CbeFlagToReview :user_cbe_data="user_cbe_data" :route="$route" v-if="showFlag($route.name)" />

      </b-navbar-nav>
    </b-navbar>


  </header>
</template>

<script>
import CbeFlagToReview from "../CbeFlagToReview";

export default {
  components: {
    CbeFlagToReview
  },
  props: {
    logo: String,
    title: String,
    user_cbe_data: Object
  },
  methods: {
    showFlag: function(page) {
      let permitted_pages = ['sections', 'questions']

      return permitted_pages.includes(page);
    }
  }
};
</script>
