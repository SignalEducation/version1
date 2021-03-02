<template>
  <section>
    <div class="answers">
      <input
        :id="answerData.id"
        v-model="question"
        type="text"
      >
    </div>
  </section>
</template>

<script>
import EventBus from "../EventBus.vue";

export default {
  components: {
    EventBus,
  },
  props: {
    answerData: {
      type: Object,
      required: true,
    },
    questionId: {
      type: Number,
      required: true,
    },
    questionScore: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      question: this.getPickedValue(),
      answerScore: 0,
      answerCorrect: false
    };
  },
  watch: {
    question(newValue) {
      this.compareValues(newValue);

      let data = {
        id: this.questionId,
        score: this.answerScore,
        correct:this.answerCorrect,
        cbe_question_id: this.questionId,
        answers_attributes: [{
          cbe_answer_id: this.answerData.id,
          content: {
            text: newValue,
            correct: this.answerCorrect
          }
        }]
      }

      EventBus.$emit("update-question-answer", data);
      this.$store.dispatch("userCbe/recordAnswer", data);
    }
  },
  methods: {
    getPickedValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[
        this.questionId
      ];
      if (initialValue != null) {
        return initialValue.answers_attributes[0].content.text;
      }

      return [];
    },
    compareValues(value) {
      const firstToCompare = this.formatStringToCompare(this.answerData.content.text);
      const secondToCompare = this.formatStringToCompare(value);

      if ( firstToCompare === secondToCompare ){
        this.answerScore = this.questionScore;
        this.answerCorrect = true;
      } else {
        this.answerScore = 0;
        this.answerCorrect = false;
      }
    },
    // for now I format the strings to check if they are equal.
    // maybe we can implement a comparison of similarity.
    formatStringToCompare(string) {
      return string.toLowerCase().trim();
    }
  }
};
</script>
