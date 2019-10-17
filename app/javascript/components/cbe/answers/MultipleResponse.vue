<template>
  <section>
    <div class="answers" v-for="answer in answers" :key="answer.id">
      <input
        type="checkbox"
        :id="answer.id"
        :value="{ id: question_id, answers: { cbe_answer_id: answer.id, content: answer.content, cbe_question_id: question_id } }"
        v-model="question"
      />
      <label :for="answer.id">{{ answer.content['text'] }}</label>
      <br />
    </div>
  </section>
</template>

<script>
export default {
  props: {
    answers: {},
    question_id: Number
  },
  data() {
    return {
      question: this.getPickedValue()
    };
  },
  watch: {
    question(newValue, oldValue) {
      this.$store.dispatch("userCbe/recordAnswer", this.getQuestionFormated(newValue));
    }
  },
  methods: {
    getPickedValue() {
      var initial_value = this.$store.state.userCbe.user_cbe_data.questions[
        this.question_id
      ];
      if (initial_value != null) {
        return this.undoQuestionFormat(initial_value);
      } else {
        return [];
      }
    },
    // format value from checkbox to fit in same format as others answers components.
    getQuestionFormated(questions) {
      var question = {};
      question.id = [...new Set(questions.map(a => a.id))][0];
      question.answers = questions.map(a => a.answers);

      return question;
    },
    // undo format value from vuex to set in component.
    undoQuestionFormat(question) {
      var questions = [];
      question.answers.filter(answers => {
        questions.push({ id: question.id, answers: answers })
      });

      return questions;
    },
  }
};
</script>
