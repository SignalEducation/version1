<template>
  <section>
    <div class="answers">
      <select v-model="question">
        <option
          v-for="answer in answersData"
          :key="`option-${answer.id}`"
          :value="{
            id: questionId,
            score: answerScore(answer),
            correct: answer.content.correct,
            cbe_question_id: questionId,
            answers_attributes: [{
              cbe_answer_id: answer.id,
              content: answer.content,
            }]
          }"
        >
          {{ answer.content.text }}
        </option>
      </select>
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
      question: this.getPickedValue()
    };
  },
  watch: {
    question(newValue) {
      if (newValue != null) {
        this.$store.dispatch("userCbe/recordAnswer", newValue);
        EventBus.$emit("update-question-answer", newValue);
      }
    }
  },
  methods: {
    getPickedValue() {
      let initialValue = this.$store.state.userCbe.user_cbe_data.questions[
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
  }
};
</script>
