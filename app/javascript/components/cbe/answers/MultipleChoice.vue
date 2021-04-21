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
        type="radio"
        :value="{
          id: questionId,
          score: answerScore(answer),
          cbe_question_id: questionId,
          correct: answer.content.correct,
          answers_attributes: [
            {
              cbe_answer_id: answer.id,
              content: answer.content,
            },
          ],
        }"
      >
      <label :for="answer.id">{{ answer.content['text'] }}</label>
      <br>
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
      EventBus.$emit("update-question-answer", newValue);
      this.$store.dispatch('userCbe/recordAnswer', newValue);
      EventBus.$emit("update-question-answer", newValue);
    },
  },
  methods: {
    getPickedValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[
        this.questionId
      ];
      if (initialValue != null) {
        initialValue.id = initialValue.cbe_question_id
        return initialValue;
      }

      return [];
    },
    answerScore(answer) {
      return answer.content.correct ? this.questionScore : 0
    }
  },
};
</script>
