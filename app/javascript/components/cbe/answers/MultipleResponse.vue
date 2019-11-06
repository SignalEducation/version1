<template>
  <section>
    <div
      v-for="answer in answersData"
      :key="answer.id"
      class="answers"
    >
      <input
        :id="answer.id"
        v-model="question"
        type="checkbox"
        :value="{ id: questionId,
                  answers: { cbe_answer_id: answer.id, content: answer.content, cbe_question_id: questionId } }"
      >
      <label :for="answer.id">{{ answer.content['text'] }}</label>
      <br>
    </div>
  </section>
</template>

<script>
export default {
  props: {
    answersData: {
      type: Array,
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
    };
  },
  watch: {
    question(newValue) {
      this.$store.dispatch("userCbe/recordAnswer", this.getQuestionFormated(newValue));
    }
  },
  methods: {
    getPickedValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[
        this.question_id
      ];
      if (initialValue != null) {
        return this.undoQuestionFormat(initialValue);
      }

      return [];
    },
    // format value from checkbox to fit in same format as others answers components.
    getQuestionFormated(questions) {
      const question = {};
      const check = this.checkAnswers();

      question.id = this.questionId;
      question.score = (check ? this.questionScore : 0);
      question.correct = check;
      question.answers = questions.map(a => a.answers);

      return question;
    },
    // undo format value from vuex to set in component.
    undoQuestionFormat(question) {
      const questions = [];

      question.answers.filter(answers => {
        questions.push({ id: question.id, answers })
      });

      return questions;
    },
    checkAnswers(){
      const check = false;

      if( this.question.length > 0 ) {
        const pickedAnswers = this.question.
                                map(a => a.answers).
                                map(answer => answer.content.correct);
        // checking if all picked answers are correct
        if (pickedAnswers.some(x => x === false)){
          return false
        }

        const correctAnswers = this.answersData.
                                 filter(answer => answer.content.correct === true).
                                 map(answer => answer.content.correct);

        // checking if all the correct answers are picked.
        return correctAnswers.length === pickedAnswers.length;
      }

      return check;
    }
  }
};
</script>
