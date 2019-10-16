<template>
  <section>
    <div class="answers">
      <input type="text" :id="answer.id" v-model="question" />
    </div>
  </section>
</template>
<script>
export default {
  props: {
    answer: {},
    question_id: Number
  },
  data() {
    return {
      question: this.getPickedValue()
    };
  },
  watch: {
    question(newValue, oldValue) {
      let check = this.compareValues(newValue);

      this.$store.dispatch("user_cbe/recordAnswer", {
        id: this.question_id,
        answers: [{
          cbe_answer_id: this.answer.id,
          content: {
            text: newValue,
            correct: check
          },
          cbe_question_id: this.question_id
        }]
      });
    }
  },
  methods: {
    getPickedValue() {
      var initial_value = this.$store.state.user_cbe.user_cbe_data.questions[
        this.question_id
      ];
      if (initial_value != null) {
        return initial_value;
      } else {
        return [];
      }
    },
    compareValues(value) {
      let firstToCompare = this.formatStringToCompare(this.answer.content.text);
      let secondToCompare = this.formatStringToCompare(value);

      return firstToCompare == secondToCompare;
    },
    // for now I format the strings to check if they are equal.
    // maybe we can implement a comparison of similarity.
    formatStringToCompare(string) {
      return string.toLowerCase().trim();
    }
  }
};
</script>
