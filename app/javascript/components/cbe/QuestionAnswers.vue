<template>
  <section>
    <!-- passing just the first answer in fill the blank cause is just one text value -->
    <FillTheBlank
      :answer="answers[0]"
      :question_id="question_id"
      v-if="question_kind == 'fill_in_the_blank'"
    />
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
import FillTheBlank from "./answers/FillTheBlank";
import MultipleChoice from "./answers/MultipleChoice";
import MultipleResponse from "./answers/MultipleResponse";

export default {
  components: {
    FillTheBlank,
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

