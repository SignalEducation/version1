<template>
  <b-tab :title="tabName">
    <div class="row">
      <div class="col-sm-8">
        <div class="form-group">
          <label for="resourceName">Name</label>
          <div class="input-group input-group-lg">
            <input
              id="resourceName"
              v-model="name"
              placeholder="Document name"
              class="form-control"
            >
          </div>

          <p
            v-if="!$v.name.required && $v.name.$error"
            class="error-message"
          >
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
            >
          </div>
          <p
            v-if="!$v.sortingOrder.required && $v.sortingOrder.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="sectionKindSelect">File</label>
          <b-form-file
            ref="inputFile"
            :state="Boolean(file)"
            placeholder="Choose a file or drop it here..."
            drop-placeholder="Drop file here..."
            @change="uploadFile"
          />
          <div class="mt-3">
            Selected file: {{ file ? file.name : '' }}
          </div>
          <p
            v-if="!$v.file.required && $v.file.$error"
            class="error-message"
          >
            file is required
          </p>
        </div>
      </div>

      <div>
        <button
          v-if="id"
          class="btn btn-primary"
          @click="updateFile"
        >
          Update File
        </button>
        <button
          v-else
          class="btn btn-primary"
          @click="saveFile"
        >
          Save File
        </button>

        <p
          v-if="updateStatus === 'ERROR'"
          class="typo__p"
        >
          Please fill the form correctly.
        </p>
        <p
          v-if="updateStatus === 'PENDING'"
          class="typo__p"
        >
          Updating...
        </p>
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
  </b-tab>
</template>

<script>
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required, numeric } from 'vuelidate/lib/validators';

export default {
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: null,
    },
    initialName: {
      type: String,
      default: '',
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
  },
  data() {
    return {
      resourceDetails: {},
      name: this.initialName,
      sortingOrder: this.initialSortingOrder,
      file: {},
      submitStatus: null,
      updateStatus: null,
    };
  },
  validations: {
    name: {
      required,
    },
    sortingOrder: {
      required,
      numeric,
    },
    file: {
      required,
    },
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : 'New Resource';
    },
  },
  methods: {
    uploadFile(e) {
      // this.file = e.target.files[0];
      [ this.file ] = e.target.files;
    },
    saveFile() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        this.resourceDetails.name = this.name;
        this.resourceDetails.document = this.file;
        this.resourceDetails.sorting_order = this.sortingOrder;

        const formData = new FormData();
        formData.append('resource[name]', this.name);
        formData.append('resource[document]', this.file);
        formData.append('resource[sorting_order]', this.sortingOrder);

        axios({
          method: 'post',
          url: `/api/v1/cbes/${this.$store.state.cbeId}/resources`,
          data: formData,
          config: { headers: { 'Content-Type': 'multipart/form-data' } },
        })
          .then(response => {
            this.createdResource = response.data;
            if (this.createdResource.id > 0) {
              this.submitStatus = 'OK';
              this.resourceDetails.id = this.createdResource.id;
              this.$emit('add-resource', this.resourceDetails);
              this.resourceDetails = {};
              this.name = this.initialName;
              this.sortingOrder = this.initialSortingOrder;
              this.file = {};
              this.$v.$reset();
            }
          })
          .catch(error => {
            this.submitStatus = 'ERROR';
            console.log(error);
          });
      }
    },
    updateFile() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = 'ERROR';
      } else {
        this.updateStatus = 'PENDING';
        this.resourceDetails.name = this.name;
        this.resourceDetails.sorting_order = this.sortingOrder;

        axios
          .patch(`/api/v1/cbes/resources/${this.id}`, {
            resource: this.resourceDetails,
          })
          .then(response => {
            this.updateStatus = 'OK';
            this.updatedResource = response.data;
            this.resourceDetails.id = this.updatedResource.id;
            this.$emit('add-resource', this.resourceDetails);
            this.resourceDetails = {};
            this.title = this.updatedResource.title;
            this.sortingOrder = this.updatedResource.sorting_order;
            this.$v.$reset();
          })
          .catch(error => {
            this.updateStatus = 'ERROR';
            console.log(error);
          });
      }
    },
  },
};
</script>
