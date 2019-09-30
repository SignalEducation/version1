<template>
  <section>
    <MultipleChoice
      :answers="answers"
      :question_id="question_id"
      v-if="question_kind == 'multiple_choice'"
    />
    <MultipleResponse
      :answers="answers"
      :question_id="question_id"
      v-if="question_kind == 'multiple_response'"
    />
  </section>
</template>

<script>
import MultipleChoice from "./answers/MultipleChoice";
import MultipleResponse from "./answers/MultipleResponse";

export default {
  components: {
    MultipleChoice,
    MultipleResponse
  },
  props: {
    answers: {},
    question_id: Number,
    question_kind: String
  }
};
</script>

