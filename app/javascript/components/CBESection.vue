<template>
  <div class="form-row form-horizontal">
    <div class="col-sm-12">
      <h4>Section</h4>
      <div class="form-group">
        <label for="colFormLabelSm">Name</label>
        <div class="input-group input-group-lg">
          <input v-model="sectionName" placeholder="Name" class="form-control" />
        </div>
      </div>
      <div class="form-group">
        <label for="colFormLabelSm">Score</label>
        <div class="input-group input-group-lg">
          <input v-model="sectionScore" placeholder="Score" class="form-control" />
        </div>
      </div>
      <!--
      <div class="form-group">
        <label for="colFormLabelSm">Section Label</label>
        <div class="input-group input-group-lg">
          <select v-model="sectionKind" class="form-control custom-select">
            <option class="col-md-8" v-for="kind in sectionKinds" v-bind:value="kind.id">
              {{ kind.name }}
            </option>
          </select>
        </div>
      </div>
      -->
      <div class="form-group">
        <label for="colFormLabelSm">Content</label>
        <div class="input-group input-group-lg">
          <input v-model="sectionContent" placeholder="Content" class="form-control" />
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
        sectionName: null,
        sectionScore: null,
        sectionKind: null,
        sectionContent: null,
        createdSection: null,
        sectionKinds: [],
        showCBEQuestion: false,
        cbeQuestionButton: false
      };
    },
    methods: {
      makeCBEQuestionVisible: function(page, index) {
        this.$store.state.showQuestions = true;
        this.showCBEQuestion = true;
      },

      saveSection: function(page, index) {
        this.sectionDetails["name"] = this.sectionName;
        this.sectionDetails["score"] = this.sectionScore;
        this.sectionDetails["content"] = this.sectionContent;
        this.sectionDetails["cbe_id"] = this.$store.state.currentCbeId;


        axios
          .post(
            "/api/v1/cbes/"+ this.$store.state.currentCbeId + '/sections', { cbe_section: this.sectionDetails }
          )
          .then(response => {
            this.createdSection = response.data;
            this.$store.commit("setCurrentSectionId", this.createdSection.id);
            console.log(this.createdSection.id);
            if (this.$store.state.currentSectionId > 0) {
              this.cbeQuestionButton = true;
              this.sectionDetails["id"] = this.createdSection.id;
              this.$emit('add-section', this.sectionDetails);
              this.sectionDetails = {};
              this.sectionName = null;
              this.sectionScore = null;
              this.sectionContent = null;
            }
          })
          .catch(error => {
            console.log(error);
          });
      }
    }
  };
</script>
