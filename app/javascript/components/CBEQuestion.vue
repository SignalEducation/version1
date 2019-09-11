<template>
  <div class="row ">
    <div class="col-sm-6">
      <div class="form-group">
        <label for="questionKindSelect">Question Type</label>
        <b-form-select
          v-model="questionKind"
          :options="questionKinds"
          id="questionKindSelect"
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
    <div class="col-sm-6">
      <div class="form-group">
        <label for="questionScore">Score</label>
        <div
          class="input-group input-group-lg"
          id="questionScore"
        >
          <input
            v-model="questionScore"
            placeholder="Score"
            class="form-control"
          />
        </div>
      </div>
    </div>
    <div class="col-sm-12">
      <div class="form-group">
        <label for="questionContent">Content</label>
        <div
          class="input-group input-group-lg"
          id="questionContent"
        >
          <textarea
            v-model="questionContent"
            placeholder="Content"
            class="form-control"
          ></textarea>
        </div>
      </div>
    </div>

    <div class="form-group">
      <button
        v-on:click="saveQuestion"
        class="btn btn-primary"
      >Save Question</button>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: ['sectionId', 'scenarioId'],
  data() {
    return {
      questionDetails: {},
      questionKind: null,
      questionContent: null,
      questionScore: null,
      selectedSelectQuestion: null,
      questionKinds: [
        'multiple_choice',
        'multiple_response',
        'complete',
        'fill_in_the_blank',
        'drag_drop',
        'dropdown_list',
        'hot_spot',
        'spreadsheet',
        'open',
      ],
    };
  },
  methods: {
    // eslint-disable-next-line no-unused-vars
    saveQuestion(page, index) {
      this.questionDetails = {};
      this.questionDetails.kind = this.questionKind;
      this.questionDetails.content = this.questionContent;
      this.questionDetails.score = this.questionScore;
      this.questionDetails.cbe_section_id = this.sectionId;
      this.questionDetails.cbe_scenario_id = this.scenarioId;
      // eslint-disable-next-line no-console
      console.log(this.questionDetails);

      axios
        .post('/api/v1/cbe/questions/', {
          question: this.questionDetails,
        })
        .then((response) => {
          this.createdQuestion = response.data;
          this.questionDetails.id = this.createdQuestion.id;
          this.$emit('add-question', this.questionDetails);
          this.questionDetails = {};
          this.questionKind = '';
          this.questionContent = '';
          this.questionScore = '';
        })
        .catch((error) => {
          // eslint-disable-next-line no-console
          console.log(error);
        });
    },
  },
};
</script>
