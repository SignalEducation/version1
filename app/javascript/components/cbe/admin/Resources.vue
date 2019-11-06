<template>
  <b-card no-body>
    <b-tabs card>
      <Resource
        v-for="resource in resources"
        :id="resource.id"
        :key="'resource-tab-' + resource.id"
        :initial-title="resource.name"
      />
      <Resource @add-resource="updateResources" />
    </b-tabs>
  </b-card>
</template>

<script>
import Resource from "./Resource.vue";

export default {
  components: {
    Resource
  },
  props: {
    resources: {
      type: Array,
      default: () => [],
    },
  },
  methods: {
    updateResources(data) {
      this.$emit("add-resource", data);
    }
  }
};
</script>
