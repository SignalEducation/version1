<template>
  <div class="row ">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="scenarioContent">Content</label>
        <div
          class="input-group input-group-lg"
          id="scenarioContent"
        >
          <textarea
            v-model="scenarioContent"
            placeholder="Content"
            class="form-control"
          ></textarea>
        </div>
      </div>
    </div>

    <div class="form-group">
      <button
        v-on:click="saveScenario"
        class="btn btn-primary"
      >Save Scenario</button>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: ['sectionId'],
  data() {
    return {
      scenarioDetails: {},
      scenarioContent: null,
    };
  },
  methods: {
    saveScenario() {
      this.scenarioDetails = {};
      this.scenarioDetails.content = this.scenarioContent;
      this.scenarioDetails.cbe_section_id = this.sectionId;

      axios
        .post('/api/v1/cbe/scenarios/', {
          scenario: this.scenarioDetails,
        })
        .then((response) => {
          this.createdScenario = response.data;
          this.scenarioDetails.id = this.createdScenario.id;
          this.$emit('add-scenario', this.scenarioDetails);
          this.scenarioDetails = {};
          this.scenarioContent = '';
        })
        .catch((error) => {
          // eslint-disable-next-line no-console
          console.log(error);
        });
    },
  },
};
</script>
