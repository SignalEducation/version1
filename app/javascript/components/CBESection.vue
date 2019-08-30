<template>
  <div class="form-row form-horizontal">
    <div class="col-sm-12">
      <h4>Section</h4>
      <div class="form-group">
        <label for="sectionName">Name</label>
        <div class="input-group input-group-lg">
          <input v-model="name" placeholder="Name" class="form-control" id="sectionName" />
        </div>
      </div>
      <div class="form-group">
        <label for="sectionScore">Score</label>
        <div class="input-group input-group-lg">
          <input v-model="score" placeholder="Score" class="form-control" id="sectionScore" />
        </div>
      </div>
      <!--
      <div class="form-group">
        <label for="colFormLabelSm">Section Label</label>
        <div class="input-group input-group-lg">
          <select v-model="kind" class="form-control custom-select">
            <option class="col-md-8" v-for="kind in sectionKinds" v-bind:value="kind.id">
              {{ kind.name }}
            </option>
          </select>
        </div>
      </div>
      -->
      <div class="form-group">
        <label for="sectionContent">Content</label>
        <div class="input-group input-group-lg">
          <input v-model="content" placeholder="Content" class="form-control" id="sectionContent" />
        </div>
      </div>

      <div>
        <button v-on:click="saveSection" class="btn btn-primary">Save Section</button>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

  export default {
    data: function() {
      return {
        sectionDetails: {},
        name: null,
        score: null,
        kind: null,
        content: null,
        sectionKinds: []
      };
    },
    methods: {
      saveSection: function() {
        this.sectionDetails["name"] = this.name;
        this.sectionDetails["score"] = this.score;
        this.sectionDetails["content"] = this.content;
        this.sectionDetails["cbe_id"] = this.$store.state.cbeId;

        axios
          .post(
            "/api/v1/cbes/"+ this.$store.state.cbeId + '/sections', { cbe_section: this.sectionDetails }
          )
          .then(response => {
            this.createdSection = response.data;
            if (this.createdSection.id > 0) {
              this.sectionDetails["id"] = this.createdSection.id;
              this.$emit('add-section', this.sectionDetails);
              this.sectionDetails = {};
              this.name = null;
              this.score = null;
              this.content = null;
            }
          })
          .catch(error => {
            console.log(error);
          });
      }
    }
  };
</script>
