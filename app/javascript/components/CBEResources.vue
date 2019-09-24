<template>
  <b-card no-body>
    <b-tabs card >
      <CBEResource
        v-for="resource in resources"
        v-bind:key="'resource-tab-' + resource.id"
        v-bind:id="resource.id"
        v-bind:initialTitle="resource.name"
      />
      <CBEResource v-on:add-resource="updateResources" />
    </b-tabs>
  </b-card>
</template>

<script>
import CBEResource from "./CBEResource";

export default {
  components: {
    CBEResource,
  },
  props: {
    resources: Array
  },
  methods: {
    updateResources: function(data) {
      this.$emit("add-resource", data);
    },
  }
};
</script>
