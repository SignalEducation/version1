<template>
  <div class="row">
    <div class="col-sm-6">
      <div class="form-group">
        <label for="scenarioName">Name</label>
        <div class="input-group input-group-lg">
          <input
              v-model="scenarioName"
              @blur="$v.scenarioName.$touch()"
              :class="'form-control ' + {error: shouldAppendErrorClass($v.scenarioName), valid: shouldAppendValidClass($v.scenarioName)}"
              id="scenarioName"
              placeholder="Name"
          />
        </div>
        <p v-if="!$v.scenarioName.required && $v.scenarioName.$error" class="error-message">field is required</p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="scenarioContent">Content</label>
        <div id="scenarioContent">
          <TinyEditor
            @blur="$v.scenarioContent.$touch()"
            :class="{error: shouldAppendErrorClass($v.scenarioContent), valid: shouldAppendValidClass($v.scenarioContent)}"
            :fieldModel.sync="scenarioContent"
            :aditionalToolbarOptions="['fullscreen code']"
            :editorId="'scenarioEditor' + '-' + sectionId + '-' + id"
          />
          <p
            v-if="!$v.scenarioContent.required && $v.scenarioContent.$error"
            class="error-message"
          >field is required</p>
        </div>
      </div>
    </div>

    <div class="form-group">
      <button
        v-if="id"
        v-on:click="updateScenario"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
      >Update Scenario</button>
      <button
        v-else
        v-on:click="saveScenario"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
      >Save Scenario</button>
      <p class="typo__p" v-if="submitStatus === 'ERROR'">Please fill the form correctly.</p>
      <p class="typo__p" v-if="submitStatus === 'PENDING'">Sending...</p>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import TinyEditor from "../../TinyEditor";
import { validationMixin } from "vuelidate";
import { required } from "vuelidate/lib/validators";

export default {
  props: {
    sectionId: Number,
    id: Number,
    initialName: String,
    initialContent: String
  },
  components: {
    TinyEditor
  },
  mixins: [validationMixin],
  data: function() {
    return {
      scenarioDetails: {},
      scenarioName: this.initialName,
      scenarioContent: this.initialContent,
      submitStatus: null
    };
  },
  validations: {
    scenarioName: {
      required
    },
    scenarioContent: {
      required
    }
  },
  methods: {
    saveScenario: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.scenarioDetails = {};
        this.scenarioDetails["name"] = this.scenarioName;
        this.scenarioDetails["content"] = this.scenarioContent;
        this.scenarioDetails["cbe_section_id"] = this.sectionId;

        axios
          .post(`/api/v1/sections/${this.sectionId}/scenarios/`, {
            scenario: this.scenarioDetails
          })
          .then(response => {
            this.createdScenario = response.data;
            this.scenarioDetails["id"] = this.createdScenario.id;
            this.$emit("add-scenario", this.scenarioDetails);
            this.scenarioDetails = {};
            this.scenarioName = null;
            this.scenarioContent = null;
            this.submitStatus = "OK";
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    updateScenario: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.scenarioDetails["name"] = this.scenarioName;
        this.scenarioDetails["content"] = this.scenarioContent;
        this.scenarioDetails["cbe_section_id"] = this.sectionId;

        axios
          .patch(`/api/v1/scenarios/${this.id}`, {
            scenario: this.scenarioDetails
          })
          .then(response => {
            this.updatedScenario = response.data;
            this.scenarioDetails["id"] = this.updatedScenario.id;
            this.$emit("update-content", this.TinyEditor);
            this.scenarioDetails = {};
            this.name = this.scenarioName;
            this.content = this.initialContent;
            this.submitStatus = "OK";
            this.$v.$reset();
          })
          .catch(error => {
            this.submitStatus = "ERROR";
          });
      }
    },
    shouldAppendValidClass(field) {
      return !field.$invalid && field.$model && field.$dirty;
    },
    shouldAppendErrorClass(field) {
      return field.$error;
    }
  }
};
</script>
