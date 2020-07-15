<template>
  <div class="row">
    <div class="col-sm-6">
      <div class="form-group">
        <label for="scenarioName">Name</label>
        <div class="input-group input-group-lg">
          <input
            v-model="scenarioName"
            :class="'form-control ' + {error: shouldAppendErrorClass($v.scenarioName), valid: shouldAppendValidClass($v.scenarioName)}"
            placeholder="Name"
            @blur="$v.scenarioName.$touch()"
          >
        </div>
        <p
          v-if="!$v.scenarioName.required && $v.scenarioName.$error"
          class="error-message"
        >
          field is required
        </p>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="scenarioContent">Content</label>
        <div id="scenarioContent">
          <TinyEditor
            :class="{error: shouldAppendErrorClass($v.scenarioContent), valid: shouldAppendValidClass($v.scenarioContent)}"
            :field-model.sync="scenarioContent"
            :aditional-toolbar-options="['fullscreen code image']"
            :editor-id="'scenarioEditor' + '-' + sectionId + '-' + id"
            @blur="$v.scenarioContent.$touch()"
          />
          <p
            v-if="!$v.scenarioContent.required && $v.scenarioContent.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>
    </div>

    <div class="form-group">
      <button
        v-if="id"
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="updateScenario"
      >
        Update Scenario
      </button>
      <button
        v-if="id"
        class="btn btn-danger"
        @click="deleteScenario"
      >
        Delete Scenario
      </button>
      <button
        v-else
        :disabled="submitStatus === 'PENDING'"
        class="btn btn-primary"
        @click="saveScenario"
      >
        Save Scenario
      </button>
      <p
        v-if="submitStatus === 'ERROR'"
        class="typo__p"
      >
        Please fill the form correctly.
      </p>
      <p
        v-if="submitStatus === 'PENDING'"
        class="typo__p"
      >
        Sending...
      </p>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { validationMixin } from "vuelidate";
import { required } from "vuelidate/lib/validators";
import TinyEditor from "../../TinyEditor.vue";

export default {
  components: {
    TinyEditor
  },
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    sectionId: {
      type: Number,
      default: null,
    },
    initialName: {
      type: String,
      default: '',
    },
    initialContent: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      scenarioDetails: {},
      scenarioName: this.initialName,
      scenarioContent: this.initialContent,
      submitStatus: null,
      deleteStatus: null
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
    saveScenario() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.scenarioDetails = {};
        this.scenarioDetails.name = this.scenarioName;
        this.scenarioDetails.content = this.scenarioContent;
        this.scenarioDetails.cbe_section_id = this.sectionId;

        axios
          .post(`/api/v1/sections/${this.sectionId}/scenarios/`, {
            scenario: this.scenarioDetails
          })
          .then(response => {
            this.createdScenario = response.data;
            this.scenarioDetails.id = this.createdScenario.id;
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
    updateScenario() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";
        this.scenarioDetails.name = this.scenarioName;
        this.scenarioDetails.content = this.scenarioContent;
        this.scenarioDetails.cbe_section_id = this.sectionId;

        axios
          .patch(`/api/v1/scenarios/${this.id}`, {
            scenario: this.scenarioDetails
          })
          .then(response => {
            this.updatedScenario = response.data;
            this.scenarioDetails.id = this.updatedScenario.id;
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
    deleteScenario() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';
          const scenarioId = this.id;
          const {sectionId} = this;


          axios
            .delete(`/api/v1/scenarios/${scenarioId}`)
            .then(response => {
              this.$emit('rm-scenario', { scenarioId, sectionId });
              this.updateStatus = 'OK';
              this.$v.$reset();
            })
            .catch(error => {
              this.updateStatus = 'ERROR';
              console.log(error);
            });
        }
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
