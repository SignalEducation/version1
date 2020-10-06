<template>
  <section>
    <div style="padding:15px;" v-html="content" >
    </div>
  </section>
</template>

<script>
export default {
  props: {
  	content: {
      type: String,
  	},
  }
}
</script>