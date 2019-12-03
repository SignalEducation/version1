<template>
  <b-card no-body>
    <b-tabs card>
      <Resource
        v-for="resource in resources"
        :id="resource.id"
        :key="'resource-tab-' + resource.id"
        :initial-name="resource.name"
        :initial-file="resource.file"
        :initial-sorting-order="resource.sorting_order"
        @rm-resource="$emit('rm-resource', resourceId)"
      />
      <Resource
        :initial-sorting-order="sortingOrderValue(resources)"
        @add-resource="updateResources"
      />
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
  methods:{
    sortingOrderValue(object) {
      let order = 1;
      if ( object ) order = object.length + 1;

      return order;
    },
    updateResources(data) {
      this.$emit("add-resource", data);
    }
  }
};
</script>
