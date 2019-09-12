<template>
  <div class="row ">
    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionName">Name</label>
        <div class="input-group input-group-lg">
          <input
            v-model="name"
            placeholder="Name"
            class="form-control"
            id="sectionName"
          />
        </div>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionKindSelect">Section Type</label>
        <b-form-select
          v-model="kind"
          :options="sectionKinds"
          id="sectionKindSelect"
          class="input-group input-group-lg"
        >
          <template slot="first">
            <option
              :value="null"
              disabled
            >-- Please select a type --</option>
          </template>
        </b-form-select>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionScore">Score</label>
        <div class="input-group input-group-lg">
          <input
            v-model="score"
            placeholder="Score"
            class="form-control"
            id="sectionScore"
          />
        </div>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="form-group">
        <label for="sectionContent">Cover Page Content</label>
        <div class="input-group input-group-lg">
          <textarea
            v-model="content"
            placeholder="Content"
            class="form-control"
            id="sectionContent"
          ></textarea>
        </div>
      </div>
    </div>

    <div>
      <button
        v-on:click="saveSection"
        class="btn btn-primary"
      >Save Section</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      sectionDetails: {},
      name: null,
      score: null,
      kind: null,
      content: null,
      sectionKinds: [ 'objective', 'objective_test_case', 'constructed_response' ]
    };
  },
  methods: {
    saveSection() {
      this.sectionDetails["name"] = this.name;
      this.sectionDetails["score"] = this.score;
      this.sectionDetails["kind"] = this.kind;
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
            this.kind = null;
            this.score = null;
            this.content = null;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
  },
};
</script>
