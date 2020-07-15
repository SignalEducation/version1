<template>
  <div class="row">
    <div class="col-sm-8">
      <div class="form-group">
        <label for="name">Name</label>
        <div class="input-group input-group-lg">
          <input
            v-model="name"
            placeholder="Exhibit name"
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

    <div class="col-sm-12">
      <div class="form-group">
        <label for="exhibitKind">Pdf/Spreadsheet</label>
        <b-form-radio v-model="exhibitKind" :name="`exhibit-kind-${id}`" value="pdf">PDF</b-form-radio>
        <b-form-radio v-model="exhibitKind" :name="`exhibit-kind-${id}`" value="spreadsheet">Spreadsheet</b-form-radio>
      </div>
    </div>

    <div class="col-sm-12" v-show="exhibitKind == 'pdf'">
      <div class="form-group">
        <div v-if="file.name" class="mt-3">
          <label>
            Selected file:
          </label>
          <a :href="file.url" target="_blank">
            {{ file.name }}
          </a>
        </div>
        <label for="sectionKindSelect">{{
          file.name ? "Change File" : "Attach File"
        }}</label>
        <b-form-file
          ref="input-file"
          :state="Boolean(file)"
          placeholder="Choose a file or drop it here..."
          drop-placeholder="Drop file here..."
          @change="attachFile"
        />
        <p v-if="!$v.file.required && $v.file.$error" class="error-message">
          file is required
        </p>
      </div>
    </div>

    <div class="col-sm-12" v-show="exhibitKind == 'spreadsheet'">
      <SpreadsheetEditor
        :initial-data="exhibitContent"
        @spreadsheet-updated="syncSpreadsheetData"
      />
    </div>

    <div>
      <button v-if="id" class="btn btn-primary" @click="updateExhibit">
        Update Exhibit
      </button>
      <button v-if="id" class="btn btn-danger" @click="deleteExhibit">
        Delete Exhibit
      </button>
      <button v-else class="btn btn-primary" @click="createExhibit">
        Create Exhibit
      </button>

      <p v-if="updateStatus === 'OK'" class="typo__p">
        Exhibit successful saved...
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
        Exhibit successful saved...
      </p>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { validationMixin } from "vuelidate";
import { required, numeric } from "vuelidate/lib/validators";
import SpreadsheetEditor from '../../SpreadsheetEditor/SpreadsheetEditor.vue';

export default {
  components: {
    SpreadsheetEditor,
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
      default: "pdf",
    },
    initalContent: {
      type: Object,
      default: () => ({}),
    },
    initialFile: {
      type: Object,
      default: () => ({}),
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    scenarioId: {
     type: Number,
    },
  },
  data() {
    return {
      exhibitsDetails: {},
      name: this.initialName,
      sortingOrder: this.initialSortingOrder,
      exhibitKind: this.initialKind,
      exhibitContent: this.initalContent,
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
    },
  },
  computed: {
    tabName() {
      return this.initialName.length > 0 ? this.initialName : "New Exhibit";
    },
  },
  methods: {
    syncSpreadsheetData(jsonData) {
      this.exhibitContent = {
        content: {
          data: jsonData
        },
      };
    },
    attachFile(e) {
      [this.attachedFile] = e.target.files;
      if (Object.keys(this.file).length === 0) {
        [this.file] = e.target.files;
      }
    },
    createExhibit() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = "ERROR";
      } else {
        this.submitStatus = "PENDING";

        const formData = new FormData();
        formData.append("exibits[name]", this.name);
        formData.append("exibits[kind]", this.exhibitKind);
        formData.append("exibits[content]", JSON.stringify(this.exhibitContent));
        formData.append("exibits[document]", this.attachedFile);
        formData.append("exibits[sorting_order]", this.sortingOrder);

        this.exhibitKind == 'pdf' ? formData.delete("exibits[content]") : formData.delete("exibits[document]")

        axios({
          method: "post",
          url: `/api/v1/scenarios/${this.scenarioId}/exhibits`,
          data: formData,
          headers: {
            "Content-Type": "multipart/form-data",
          },
        })
          .then((response) => {
            this.exhibitDetails = response.data;
            if (this.exhibitDetails.id > 0) {
              this.submitStatus = "OK";
              this.$emit("add-scenario-exhibit", this.exhibitDetails);
              this.exhibitDetails = {};
              this.name = this.initialName;
              this.exhibitContent = {};
              this.exhibitKind = 'pdf';
              this.sortingOrder += 1;
              this.file = {};
              this.attachedFile = null;
              this.$refs["input-file"].reset();
              this.$v.$reset();
            }
          })
          .catch((error) => {
            this.submitStatus = "ERROR";
            console.log(error);
          });
      }
    },
    updateExhibit() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = "ERROR";
      } else {
        this.updateStatus = "PENDING";

        const formData = new FormData();
        formData.append("exibits[name]", this.name);
        formData.append("exibits[kind]", this.exhibitKind);
        formData.append("exibits[content]", JSON.stringify(this.exhibitContent));
        formData.append("exibits[document]", this.attachedFile);
        formData.append("exibits[sorting_order]", this.sortingOrder);

        this.exhibitKind == 'pdf' ? formData.delete("exibits[content]") : formData.delete("exibits[document]")

        axios({
          method: "patch",
          url: `/api/v1/exhibits/${this.id}`,
          data: formData,
          headers: {
            "Content-Type": "multipart/form-data",
          },
        })
          .then((response) => {
            this.exhibitDetails = response.data;
            if (this.exhibitDetails.id > 0) {
              this.updateStatus = "OK";
              this.exhibitDetails = {};
              this.name = this.initialName;
              this.exhibitContent = this.initalContent;
              this.sortingOrder += 1;
              this.file = {};
              this.attachedFile = null;
              this.$refs["input-file"].reset();
              this.$v.$reset();
            }
          })
          .catch((error) => {
            this.updateStatus = "ERROR";
            console.log(error);
          });
      }
    },
    deleteExhibit() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';

          axios({
            method: 'delete',
            url: `/api/v1/exhibits/${this.id}`,
          }).then(response => {
            this.$emit('rm-scenario-exhibit', this.id);
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
