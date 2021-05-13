<template>
  <section class="outside-modals">
    <div class="exhibits-sidebar">
      <div class="exhibits" v-if="scenarioData">
        <VueModal
          v-for="exhibit in scenarioData.exhibits"
          :key="exhibit.id"
          :componentType="exhibit.kind"
          :componentName="exhibit.name"
          :componentModal="exhibit.modal"
          :currentFile="exhibit.document"
          :componentSpreadsheetData="exhibit.content"
        />
      </div>
    </div>
  </section>
</template>

<script>
import axios from "axios";
import VueModal from "../../components/VueModal.vue";

export default {
  components: {
    VueModal
  },
  props: {
    componentType: {
      type: String,
      default: "",
    },
    componentName: {
      type: String,
      default: "",
    },
    componentModal: {
      type: Boolean,
      default: false,
    },
    componentSpreadsheetData: {
      type: Object,
      default: () => ({}),
    },
    currentFile: {
      type: Object,
      default: () => ({}),
    },
    componentIcon: {
      type: String,
      default: "",
    },
    mainColor: {
      type: String,
      default: "#F2F2F2",
    },
    textColor: {
      type: String,
      default: "#000000",
    },
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
