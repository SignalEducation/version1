<template>
  <section>
    <div class="cbe-content">
      <div class="header">
        <h1>{{ cbe_data.name }}</h1>
        <h3>{{ cbe_data.title }}</h3>
      </div>

      <div class="content">
        <p>{{ cbe_data.content }}</p>
      </div>
    </div>
  </section>
</template>

<script>
import { mapGetters } from 'vuex'


export default {
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbeData'
    })
  }
}
</script>

