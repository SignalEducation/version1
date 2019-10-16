<template>
  <section>
    <div class="answers">
      <select v-model="question">
        <option
          v-for="answer in answers"
          :key="`option-${answer.id}`"
          :value="{
            id: question_id,
            answers: [{
              cbe_answer_id: answer.id,
              content: answer.content,
              cbe_question_id: question_id
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
      this.$store.dispatch("user_cbe/recordAnswer", newValue);
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
    }
  }
};
</script>
