<template>
  <div class="row">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="scenarioContent">Content</label>
        <div class="input-group input-group-lg" id="scenarioContent">
          <TinyEditor
            :fieldModel.sync="scenarioContent"
            :aditionalToolbarOptions="['fullscreen']"
            :editorId="'scenarioEditor'"
          />
        </div>
      </div>
    </div>

    <div class="form-group">
      <button v-on:click="saveScenario" class="btn btn-primary">Save Scenario</button>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import TinyEditor from "./TinyEditor";

export default {
  props: ["sectionId"],
  components: {
    TinyEditor
  },
  data: function() {
    return {
      scenarioDetails: {},
      scenarioContent: null
    };
  },
  methods: {
    saveScenario: function() {
      this.scenarioDetails = {};
      this.scenarioDetails["content"] = this.scenarioContent;
      this.scenarioDetails["cbe_section_id"] = this.sectionId;

      axios
        .post("/api/v1/cbe/scenarios/", {
          scenario: this.scenarioDetails
        })
        .then(response => {
          this.createdScenario = response.data;
          this.scenarioDetails["id"] = this.createdScenario.id;
          this.$emit("add-scenario", this.scenarioDetails);
          this.scenarioDetails = {};
          this.scenarioContent = "";
        })
        .catch(error => {
          console.log(error);
        });
    }
  }
};
</script>
