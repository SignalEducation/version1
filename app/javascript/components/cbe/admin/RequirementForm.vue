<template>
  <div class="row">
    <div class="col-sm-8">
      <div class="form-group">
        <label for="name">Name</label>
        <div class="input-group input-group-lg">
          <input
            id="requirementName"
            v-model="name"
            placeholder="requirement name"
            class="form-control"
          />
        </div>

        <p v-if="!$v.name.required && $v.name.$error" class="error-message">
          field is required
        </p>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="form-group">
        <label for="sortingOrder">Sorting Order</label>
        <div class="input-group input-group-lg">
          <input
            id="sortingOrder"
            v-model="sortingOrder"
            placeholder="Sorting Order"
            class="form-control"
            type="number"
          />
        </div>
        <p
          v-if="!$v.sortingOrder.required && $v.sortingOrder.$error"
          class="error-message"
        >
          field is required
        </p>
      </div>
    </div>

    <div class="col-sm-8">
      <div class="form-group">
        <label for="requirementKind">Type</label>
        <b-form-radio v-model="requirementKind" name="requirement-kind" value="requirement">Requirement</b-form-radio>
        <b-form-radio v-model="requirementKind" name="requirement-kind" value="task">Task</b-form-radio>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="form-group">
        <label for="requirementScore">Score</label>
        <div
          id="requirementScore"
          class="input-group input-group-lg"
        >
          <input
            id="requirementScore"
            v-model="requirementScore"
            placeholder="Score"
            type="decimal"
            :class="
              'form-control ' +
                {
                  error: shouldAppendErrorClass($v.requirementScore),
                  valid: shouldAppendValidClass($v.requirementScore),
                }
            "
            @blur="$v.requirementScore.$touch()"
          >
        </div>
        <p
          v-if="!$v.requirementScore.required && $v.requirementScore.$error"
          class="error-message"
        >
          field is required.
        </p>
        <p
          v-if="!$v.requirementScore.between && $v.requirementScore.$error"
          class="error-message"
        >
          must be between {{ $v.requirementScore.$params.between.min }} and
          {{ $v.requirementScore.$params.between.max }}.
        </p>
      </div>
    </div>

    <div class="col-sm-12">
      <TinyEditor
        :class="{error: shouldAppendErrorClass($v.requirementContent), valid: shouldAppendValidClass($v.requirementContent)}"
        :field-model.sync="requirementContent"
        :aditional-toolbar-options="['fullscreen code image']"
        :editor-id="'requirementContent' + '-' + scenarioId + '-' + id"
        @blur="$v.requirementContent.$touch()"
      />
      <p
        v-if="!$v.requirementContent.required && $v.requirementContent.$error"
        class="error-message"
      >
        field is required
      </p>
    </div>

    <br />

    <div class="col-sm-12">
      <button v-if="id" class="btn btn-primary" @click="updateRequirement">
        Update requirement
      </button>
      <button v-if="id" class="btn btn-danger" @click="deleteRequirement">
        Delete requirement
      </button>
      <button v-else class="btn btn-primary" @click="createRequirement">
        Create requirement
      </button>

      <p v-if="updateStatus === 'OK'" class="typo__p">
        requirement successful saved...
      </p>
      <p v-if="updateStatus === 'ERROR'" class="typo__p">
        Please fill the form correctly.
      </p>
      <p v-if="updateStatus === 'PENDING'" class="typo__p">
        Updating...
      </p>
      <p v-if="submitStatus === 'ERROR'" class="typo__p">
        Please fill the form correctly.
      </p>
      <p v-if="submitStatus === 'PENDING'" class="typo__p">
        Sending...
      </p>
      <p v-if="submitStatus === 'OK'" class="typo__p">
        requirement successful saved...
      </p>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { validationMixin } from "vuelidate";
import { required, numeric, decimal, between } from "vuelidate/lib/validators";
import TinyEditor from "../../TinyEditor.vue";

export default {
  components: {
    TinyEditor,
  },
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    initialName: {
      type: String,
      default: "",
    },
     initialKind: {
      type: String,
      default: "requirement",
    },
    initialScore: {
      type: Number,
      default: null,
    },
    initialContent: {
      type: String,
      default: "",
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    scenarioId: {
      type: Number,
      default: null,
    },
  },
  data() {
    return {
      requirementsDetails: {},
      name: this.initialName,
      sortingOrder: this.initialSortingOrder,
      requirementKind: this.initialKind,
      requirementScore: this.initialScore,
      requirementContent: this.initialContent,
      submitStatus: null,
      updateStatus: null,
    };
  },
  validations: {
    name: {
      required,
    },
    requirementContent: {
      required,
    },
    requirementScore: {
      required,
      decimal,
      between: between(1, 100),
    },
    sortingOrder: {
      required,
      numeric,
    },
    file: {
    },
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : "New requirement";
    },
  },
  methods: {
    createRequirement() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";

        const formData = new FormData();
        formData.append("requirements[name]", this.name);
        formData.append("requirements[sorting_order]", this.sortingOrder);
        formData.append("requirements[kind]", this.requirementKind);
        formData.append("requirements[score]", this.requirementScore);
        formData.append("requirements[content]", this.requirementContent);

        this.requirementKind == 'pdf' ? formData.delete("exibits[content]") : formData.delete("exibits[document]")

        axios({
          method: "post",
          url: `/api/v1/scenarios/${this.scenarioId}/requirements`,
          data: formData,
        })
          .then((response) => {
            this.requirementDetails = response.data;
            if (this.requirementDetails.id > 0) {
              this.submitStatus = "OK";
              this.$emit("add-scenario-requirement", this.requirementDetails);
              this.requirementDetails = {};
              this.name = this.initialName;
              this.requirementContent = initalContent;
              this.requirementKind = 'requirement';
              this.requirementScore = '0.0';
              this.sortingOrder += 1;
              this.$v.$reset();
            }
          })
          .catch((error) => {
            this.submitStatus = "ERROR";
            console.log(error);
          });
      }
    },
    updateRequirement() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = "ERROR";
      } else {
        this.updateStatus = "PENDING";

        const formData = new FormData();
        formData.append("requirements[name]", this.name);
        formData.append("requirements[sorting_order]", this.sortingOrder);
        formData.append("requirements[kind]", this.requirementKind);
        formData.append("requirements[score]", this.requirementScore);
        formData.append("requirements[content]", this.requirementContent);

        axios({
          method: "patch",
          url: `/api/v1/requirements/${this.id}`,
          data: formData,
        })
          .then((response) => {
            this.requirementDetails = response.data;
            if (this.requirementDetails.id > 0) {
              this.updateStatus = "OK";
              this.$v.$reset();
            }
          })
          .catch((error) => {
            this.updateStatus = "ERROR";
            console.log(error);
          });
      }
    },
    deleteRequirement() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';

          axios({
            method: 'delete',
            url: `/api/v1/requirements/${this.id}`,
          }).then(response => {
            this.$emit('rm-scenario-requirement', this.id);
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
      if (typeof field !== 'undefined') {
        return !field.$invalid && field.$model && field.$dirty;
      }
    },
    shouldAppendErrorClass(field) {
      if (typeof field !== 'undefined') {
        return field.$error;
      }
    },
  },
};
</script>
