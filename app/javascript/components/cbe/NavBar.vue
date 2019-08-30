<template>
  <section>
    <!-- TODO(Giordano), use props in this component instead set path, brand and brand text mannuality. -->
    <b-navbar toggleable="lg" type="dark" variant="info">
      <router-link to="/" v-slot="{ href, route, navigate, isActive, isExactActive }">
        <b-navbar-brand :href="href" @click="navigate">Cbe</b-navbar-brand>
      </router-link>

      <b-collapse id="nav-text-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-text>Computer Based Exam</b-nav-text>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
  </section>
</template>
