<template>
  <section>
    <div class="answers" v-for="answer in answers" :key="answer.id">
      <input
        type="radio"
        :id="answer.id"
        :value="{ id: question_id, answers: [{ cbe_answer_id: answer.id, content: answer.content, cbe_question_id: question_id }] }"
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
      this.$store.dispatch("userCbe/recordAnswer", newValue);
    }
  },
  methods: {
    getPickedValue() {
      var initial_value = this.$store.state.userCbe.user_cbe_data.questions[
        this.question_id
      ];
      if (initial_value != null) {
        return initial_value;
      } else {
        return [];
      }
    }
  }
};
</script>
