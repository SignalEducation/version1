<template>
  <div class="row">
    <div class="col-sm-8">
      <div class="form-group">
        <label for="kind">Type</label>
        <b-form-select
            id="kindSelect"
            v-model="responseOptionKind"
            :options="kindOptions"
            class="input-group input-group-lg"
          >
            <template slot="first">
              <option
                :value="null"
                disabled
              >
                -- Please select a course --
              </option>
            </template>
          </b-form-select>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="form-group" v-if="responseOptionKind == 'multiple_open'">
        <label for="Quantity">Quantity</label>
        <div class="input-group input-group-lg">
          <input
            v-model="responseOptionQuantity"
            class="form-control"
            type="number"
          />
        </div>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="form-group">
        <label for="responseOptionSortingOrder">Sorting Order</label>
        <div class="input-group input-group-lg">
          <input
            id="sortingOrder"
            v-model="responseOptionSortingOrder"
            placeholder="Sorting Order"
            class="form-control"
            type="number"
          />
        </div>
        <p
          v-if="!$v.responseOptionSortingOrder.required && $v.responseOptionSortingOrder.$error"
          class="error-message"
        >
          field is required
        </p>
      </div>
    </div>

    <div class="col-sm-12">
      <button v-if="id" class="btn btn-primary" @click="updateResponseOption">
        Update Response Option
      </button>
      <button v-if="id" class="btn btn-danger" @click="deleteResponseOption">
        Delete Response Option
      </button>
      <button v-else class="btn btn-primary" @click="createResponseOption">
        Create Response Option
      </button>

      <p v-if="updateStatus === 'OK'" class="typo__p">
        Response Option successful saved...
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
        Response Option successful saved...
      </p>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { validationMixin } from "vuelidate";
import { required, numeric, between } from "vuelidate/lib/validators";

export default {
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    initialKind: {
      type: String,
      default: "",
    },
    initialQuantity: {
      type: Number,
      default: null,
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
      responseOptionDetails: {},
      responseOptionKind: this.initialKind,
      responseOptionQuantity: this.initialQuantity,
      responseOptionSortingOrder: this.initialSortingOrder,
      kindOptions: [ { value: 'open', text:  "Word Processor" },
                     { value: 'multiple_open', text:  "Slides" },
                     { value: 'spreadsheet', text:  "Spreadsheet" } ],
      submitStatus: null,
      updateStatus: null,
      deleteStatus: null,
    };
  },
  validations: {
    responseOptionKind: {
      required,
    },
    responseOptionSortingOrder: {
      required,
      numeric,
    },
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : "New Response Option";
    },
  },
  methods: {
    createResponseOption() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";


        if (this.responseOptionKind != 'multiple_open') this.responseOptionQuantity = null

        const formData = new FormData();
        formData.append("response_options[kind]", this.responseOptionKind);
        formData.append("response_options[quantity]", this.responseOptionQuantity);
        formData.append("response_options[sorting_order]", this.responseOptionSortingOrder);

        axios({
          method: "post",
          url: `/api/v1/scenarios/${this.scenarioId}/response_options`,
          data: formData,
        })
          .then((response) => {
            this.responseOptionDetails = response.data;
            if (this.responseOptionDetails.id > 0) {
              this.submitStatus = "OK";
              this.$emit("add-scenario-response-option", this.responseOptionDetails);
              this.responseOptionDetails = {};
              this.responseOptionKind = "";
              this.responseOptionQuantity = null;
              this.responseOptionSortingOrder += 1;
              this.$v.$reset();
            }
          })
          .catch((error) => {
            this.submitStatus = "ERROR";
            console.log(error);
          });
      }
    },
    updateResponseOption() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = "ERROR";
      } else {
        this.updateStatus = "PENDING";

        if (this.responseOptionKind != 'multiple_open') this.responseOptionQuantity = null

        const formData = new FormData();
        formData.append("response_options[kind]", this.responseOptionKind);
        formData.append("response_options[quantity]", this.responseOptionQuantity);
        formData.append("response_options[sorting_order]", this.responseOptionSortingOrder);

        axios({
          method: "patch",
          url: `/api/v1/response_options/${this.id}`,
          data: formData,
        })
          .then((response) => {
            this.responseOptionDetails = response.data;
            if (this.responseOptionDetails.id > 0) {
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
    deleteResponseOption() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';

          axios({
            method: 'delete',
            url: `/api/v1/response_options/${this.id}`,
          }).then(response => {
            this.$emit('rm-scenario-response-option', this.id);
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
  },
};
</script>
