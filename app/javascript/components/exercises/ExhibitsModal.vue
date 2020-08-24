<template>
  <section>
    <div class="exhibits-sidebar">
      <div class="exhibits" v-if="scenarioData">
        <CbeExhibitsModal
          v-for="exhibit in scenarioData.exhibits"
          :key="exhibit.id"
          :exhibitType="exhibit.kind"
          :exhibitName="exhibit.name"
          :exhibitModal="exhibit.modal"
          :currentFile="exhibit.document"
          :exhibitSpreadsheetData="exhibit.content"
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
    this.getExhibtsData();
  },
  methods: {
    getExhibtsData() {
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

<style>
.window[data-v-300294cc] {
    display: flex;
    flex-flow: column;
    /* position: absolute; */
    border-radius: 4pt 4pt 0 0;
    left: -500px !important;
    top: -150px !important;
}
</style>
