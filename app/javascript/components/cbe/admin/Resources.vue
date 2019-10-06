<template>
  <b-card no-body>
    <b-tabs card>
      <Resource
        v-for="resource in resources"
        v-bind:key="'resource-tab-' + resource.id"
        v-bind:id="resource.id"
        v-bind:initialTitle="resource.name"
      />
      <Resource v-on:add-resource="updateResources" />
    </b-tabs>
  </b-card>
</template>

<script>
import Resource from "./Resource";

export default {
  components: {
    Resource
  },
  props: {
    resources: Array
  },
  methods: {
    updateResources: function(data) {
      this.$emit("add-resource", data);
    }
  }
};
</script>
