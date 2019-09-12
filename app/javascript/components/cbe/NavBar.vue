<template>
  <header class="header">
    <b-navbar toggleable="lg" type="dark">
      <router-link to="/" v-slot="{ href, route, navigate, isActive, isExactActive }">
        <b-navbar-brand :href="href" @click="navigate">{{ logo }}</b-navbar-brand>
      </router-link>
    </b-navbar>

    <div class="nav-scroller bg-white shadow-sm">
      <nav class="nav nav-underline">
        <b-nav-text>{{ title }}</b-nav-text>
      </nav>
    </div>
  </header>
</template>

<script>
export default {
  props: {
    logo: String,
    title: String
  }
};
</script>
