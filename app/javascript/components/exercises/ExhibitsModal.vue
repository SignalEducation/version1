<template>
  <section class="outside-modals">
    <div class="exhibits-sidebar">
      <div class="exhibits" v-if="scenarioData">
        <CbeExhibitsModal
          v-for="exhibit in scenarioData.exhibits"
          :key="exhibit.id"
          :componentType="exhibit.kind"
          :componentName="exhibit.name"
          :componentModal="exhibit.modal"
          :currentFile="exhibit.document"
          :componentContentData="exhibit.content"
        />
      </div>
    </div>
  </section>
</template>

<script>
import axios from "axios";
import CbeExhibitsModal from "../../components/cbe/CbeExhibitsModal.vue";

export default {
  components: {
    CbeExhibitsModal,
  },
  data() {
    return {
      cbeId: this.$parent.cbeId,
      scenarioId: this.$parent.scenarioId,
      scenarioData: null,
    };
  },
  mounted() {
    this.getExhibitsData();
  },
  methods: {
    getExhibitsData() {
      axios
        .get(`/api/v1/cbes/${this.cbeId}/scenarios/${this.scenarioId}`)
        .then((response) => {
          this.scenarioData = response.data;
        });

      return "loaded";
    },
  },
};
</script>
