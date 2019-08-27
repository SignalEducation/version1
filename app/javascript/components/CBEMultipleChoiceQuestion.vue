<template>
  <div>
    <div class="form-group">
      <label for="colFormLabelSm">Question Name</label>
      <div class="input-group input-group-lg">
        <input v-model="questionName" placeholder="Question Name" class="form-control" />
      </div>
    </div>
    <div class="form-group">
      <label for="colFormLabelSm">Question Description</label>
      <div class="input-group input-group-lg">
        <input v-model="questionDescription" placeholder="Question Description" class="form-control"/>
      </div>
    </div>

    <div>
      <div class="form-group">
        <div class="input-group input-group-lg">
          <input v-model="question_1" placeholder="Choice 1 Text" />
        </div>
        <input type="radio" id="one" value="1" v-model="correctAnswer" />
      </div>

      <div class="form-group">
        <div class="input-group input-group-lg" placeholder="Choice 2">
          <input v-model="question_2" placeholder="Choice 2 Text" />
        </div>
        <input type="radio" id="two" value="2" v-model="correctAnswer" />
      </div>

      <div class="form-group">
        <div class="input-group input-group-lg">
          <input v-model="question_3" placeholder="Choice 3 Text" />
        </div>
        <input type="radio" id="three" value="3" v-model="correctAnswer" />
      </div>

      <div class="form-group">
        <div class="input-group input-group-lg">
          <input v-model="question_4" placeholder="Choice 4 Text" />
        </div>
        <input type="radio" id="four" value="4" v-model="correctAnswer" />
      </div>

      <div class="form-group">
        <button v-on:click="saveNewMultipleChoiceQuestion" class="btn btn-primary">Save</button>
      </div>

      <div class="form-group">
        <span
          class="badge badge-pill badge-primary"
        >Selected Section {{this.$store.state.currentSectionId}}</span>
        <span class="badge badge-pill badge-primary">Current Answer {{this.correctAnswer}}</span>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

  export default {
    data: function() {
      return {
        questionDetails: {},
        questionName: null,
        questionDescription: null,
        correctAnswer: null,
        selectedSelectQuestion: null,
        showChoices: false,
        question_1: null,
        question_2: null,
        question_3: null,
        question_4: null,
        multipleChoiceDetails: []
      };
    },
    methods: {
        addSection: function (page, index) {
            this.questionDetails['name'] = this.sectionName
            this.questionDetails['scenario_label'] = this.sectionLabel
            this.questionDetails['scenario_description'] = this.sectionDescription
            this.questionDetails['cbe_id'] = this.$store.state.currentCbeId

            axios.post('http://localhost:3000/api/cbes/' + this.$store.state.currentCbeId + 'create_section', {cbe_section: this.sectionDetails})
                .then(response => {
                    this.createdSection = response.data
                })
                .catch(error => {
                    console.log(error)
                })
        },
      saveNewMultipleChoiceQuestion: function(page, index) {
        this.multipleChoiceDetails = {};
        this.multipleChoiceDetails["cbe_section_id"]      = this.$store.state.currentSectionId;
        this.multipleChoiceDetails["name"]                = this.questionName;
        this.multipleChoiceDetails["questionDescription"] = this.questionDescription;
        this.multipleChoiceDetails["question_1"]          = this.question_1;
        this.multipleChoiceDetails["question_2"]          = this.question_2;
        this.multipleChoiceDetails["question_3"]          = this.question_3;
        this.multipleChoiceDetails["question_4"]          = this.question_4;
        this.multipleChoiceDetails["correctAnswer"]       = this.correctAnswer;

        console.log(this.multipleChoiceDetails);

        {cbe_multiple_choice_question: this.cbeDetails;}
        axios
          .post("http://localhost:3000/api/v1/cbe/multiple_choice_questions/", {
            cbe_multiple_choice_question: this.multipleChoiceDetails
          })
          .then(response => {
            console.log(this.multipleChoiceDetails);
            console.log(response.status);
            console.log(response.data);
          })
          .catch(error => {
            console.log(error);
          });
      }
    }
  };
</script>
