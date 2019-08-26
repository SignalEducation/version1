<template>
  <div class="form-row form-horizontal">
    <div class="col-sm-12">
      <h4>Question</h4>

      <div class="form-group">
        <label for="colFormLabelSm">Kind</label>
        <div class="input-group input-group-lg">
          <input v-model="questionKind" placeholder="Kind" class="form-control" />
        </div>
      </div>
      <div class="form-group">
        <label for="colFormLabelSm">Content</label>
        <div class="input-group input-group-lg">
          <input v-model="questionContent" placeholder="Content" class="form-control"/>
        </div>
      </div>
      <div class="form-group">
        <label for="colFormLabelSm">Score</label>
        <div class="input-group input-group-lg">
          <input v-model="questionScore" placeholder="Score" class="form-control"/>
        </div>
      </div>


      <div class="form-group">
        <button v-on:click="saveQuestion" class="btn btn-primary">Save Question</button>
      </div>

    </div>
  </div>
</template>

<script>
  import axios from "axios";

  export default {
    props: ['sectionId'],
    data: function() {
      return {
        questionDetails: {},
        questionKind: null,
        questionContent: null,
        questionScore: null,
        selectedSelectQuestion: null
      };
    },
    methods: {
      saveQuestion: function(page, index) {
        this.questionDetails = {};
        this.questionDetails['kind'] = this.questionKind;
        this.questionDetails['content'] = this.questionContent;
        this.questionDetails['score'] = this.questionScore;
        this.questionDetails['cbe_section_id'] = this.sectionId;

        //this.$store.commit('addCbeQuestion', this.questionDetails);

        axios
          .post("http://localhost:3000/api/v1/cbe/questions/", {
            question: this.questionDetails
          })
          .then(response => {
            console.log(response.status);
            console.log(response.data);
            this.$emit('add-question', this.questionDetails);
            this.questionDetails = {};
            this.questionKind = '';
            this.questionContent = '';
            this.questionScore = '';
          })
          .catch(error => {
            console.log(error);
          });
      }
    }
  };
</script>
