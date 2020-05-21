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
          <div
            v-if="file.name"
            class="mt-3"
          >
            <label>
              Selected file:
            </label>
            <a
              :href="file.url"
              target="_blank"
            >
              {{ file.name }}
            </a>
          </div>
          <label for="sectionKindSelect">{{ file.name ? 'Change File' : 'Attach File' }}</label>
          <b-form-file
            ref="input-file"
            :state="Boolean(file)"
            placeholder="Choose a file or drop it here..."
            drop-placeholder="Drop file here..."
            @change="attachFile"
          />
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
          v-if="id"
          class="btn btn-danger"
          @click="deleteFile"
        >
          Delete File
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
    initialFile: {
      type: Object,
      default: () => ({}),
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    totalResources: {
      type: Number,
      default: 0,
    }
  },
  data() {
    return {
      resourceDetails: {},
      name: this.initialName,
      sortingOrder: this.initialSortingOrder,
      file: this.initialFile,
      attachedFile: null,
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
    attachFile(e) {
      [ this.attachedFile ] = e.target.files;
      if (Object.keys(this.file).length === 0) { [ this.file ] = e.target.files };
    },
    saveFile() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';

        const formData = new FormData();
        formData.append('resource[name]', this.name);
        formData.append('resource[document]', this.attachedFile);
        formData.append('resource[sorting_order]', this.sortingOrder);

        axios({
          method: 'post',
          url: `/api/v1/cbes/${this.$store.state.cbeId}/resources`,
          data: formData,
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        })
          .then(response => {
            this.resourceDetails = response.data;
            if (this.resourceDetails.id > 0) {
              this.submitStatus = 'OK';
              this.$emit('add-resource', this.resourceDetails);
              this.resourceDetails = {};
              this.name = this.initialName;
              this.sortingOrder += 1;
              this.file = {};
              this.attachedFile = null;
              this.$refs['input-file'].reset()
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
        const formData = new FormData();
        formData.append('resource[name]', this.name);
        formData.append('resource[sorting_order]', this.sortingOrder);
        if (this.attachedFile) { formData.append('resource[document]', this.attachedFile) };

        axios({
          method: 'patch',
          url: `/api/v1/cbes/${this.$store.state.cbeId}/resources/${this.id}`,
          data: formData,
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-CSRF-Token': document.getElementsByTagName('meta')['csrf-token'].getAttribute('content')
          },
        })
          .then(response => {
            this.updateStatus = 'OK';
            this.resourceDetails = response.data;
            this.$emit('add-resource', this.resourceDetails);
            this.title = this.resourceDetails.title;
            this.sortingOrder = this.resourceDetails.sorting_order;
            this.file = this.resourceDetails.file;
            this.attachedFile = null;
            this.$v.$reset();
          })
          .catch(error => {
            this.updateStatus = 'ERROR';
            console.log(error);
          });
      }
    },
    deleteFile() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';
          const resourceId = this.id;
          axios({
            method: 'delete',
            url: `/api/v1/cbes/${this.$store.state.cbeId}/resources/${resourceId}`,
          }).then(response => {
            this.$emit('rm-resource', resourceId);
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
