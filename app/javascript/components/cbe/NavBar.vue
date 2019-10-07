<template>
  <header class="header fixed-top" id="cbe-nav-header">
    <b-navbar toggleable="lg" type="dark">
      <router-link to="/" v-slot="{ href, route, navigate, isActive, isExactActive }">
        <b-navbar-brand :href="href" @click="navigate">{{ logo }}</b-navbar-brand>
      </router-link>

      <CbeFlagToReview :user_cbe_data="user_cbe_data" :route="$route" v-if="showFlag($route.name)" />
    </b-navbar>

    <div class="nav-scroller">
      <nav class="nav nav-underline bg-cbe-gray">
        <b-nav-text>Calculator</b-nav-text>
        <b-nav-text>Scratch Pad</b-nav-text>
      </nav>
    </div>

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
