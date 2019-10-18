<template>
  <b-tab :title="tabName">
    <div class="row">
      <div class="col-sm-8">
        <div class="form-group">
          <label for="resourceName">Name</label>
          <div class="input-group input-group-lg">
            <input
              v-model="name"
              placeholder="Document name"
              class="form-control"
              id="resourceName"
            />
          </div>
        </div>
      </div>

      <div class="col-sm-4">
        <div class="form-group">
          <label for="sortingOrder">Sorting Order</label>
          <div class="input-group input-group-lg">
            <input v-model="sortingOrder" placeholder="Sorting Order" class="form-control" id="sortingOrder" type="number" />
          </div>
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
          ></b-form-file>
          <div class="mt-3">Selected file: {{ file ? file.name : '' }}</div>
        </div>
      </div>

      <div>
        <button v-if="id" v-on:click="updateFile" class="btn btn-primary">Update File</button>
        <button v-else v-on:click="saveFile" class="btn btn-primary">Save File</button>
      </div>
    </div>
  </b-tab>
</template>

<script>
import axios from "axios";

export default {
  props: {
    id: Number,
    initialName: {
      type: String,
      default: ""
    },
    initialSortingOrder: {
      type: Number,
      default: 1
    }
  },
  data: function() {
    return {
      resourceDetails: {},
      name: this.initialName,
      sortingOrder: this.initialSortingOrder,
      file: {}
    };
  },
  computed: {
    tabName: function() {
      return this.initialName.length > 0 ? this.initialName : "New Resource";
    }
  },
  methods: {
    uploadFile: function(e) {
      this.file = e.target.files[0];
    },
    saveFile: function() {
      this.resourceDetails["name"] = this.name;
      this.resourceDetails["document"] = this.file;
      this.resourceDetails["sorting_order"] = this.sortingOrder;

      let formData = new FormData();
      formData.append("resource[name]", this.name);
      formData.append("resource[document]", this.file);
      formData.append("resource[sorting_order]", this.sortingOrder);

      axios({
        method: "post",
        url: `/api/v1/cbes/${this.$store.state.cbeId}/resources`,
        data: formData,
        config: { headers: { "Content-Type": "multipart/form-data" } }
      })
        .then(response => {
          this.createdResource = response.data;
          if (this.createdResource.id > 0) {
            this.resourceDetails["id"] = this.createdResource.id;
            this.$emit("add-resource", this.resourceDetails);
            this.resourceDetails = {};
            this.name = this.initialName;
            this.sortingOrder = this.initialSortingOrder;
            this.file = {};
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    updateFile: function() {
      this.resourceDetails["name"] = this.name;
      this.resourceDetails["sorting_order"] = this.sortingOrder;

      axios
        .patch(`/api/v1/cbes/resources/${this.id}`, {
          resource: this.resourceDetails
        })
        .then(response => {
          this.updatedResource = response.data;
          this.resourceDetails["id"] = this.updatedResource.id;
          this.$emit("add-resource", this.resourceDetails);
          this.resourceDetails = {};
          this.title = this.updatedResource.title;
          this.sortingOrder = this.updatedResource.sorting_order;
        })
        .catch(error => {
          console.log(error);
        });
    }
  }
};
</script>
