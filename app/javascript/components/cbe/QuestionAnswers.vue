<template>
  <section>
    <DropdownList
      :answers="answers"
      :question_id="question_id"
      v-if="question_kind == 'dropdown_list'"
    />
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
    <OpenAnswer
      :question_id="question_id"
      v-if="question_kind == 'open'"
    />
  </section>
</template>

<script>
import DropdownList from "./answers/DropdownList";
import FillTheBlank from "./answers/FillTheBlank";
import MultipleChoice from "./answers/MultipleChoice";
import MultipleResponse from "./answers/MultipleResponse";
import OpenAnswer from "./answers/OpenAnswer";



export default {
  components: {
    DropdownList,
    FillTheBlank,
    MultipleChoice,
    MultipleResponse,
    OpenAnswer
  },
  props: {
    answers: {},
    question_id: Number,
    question_kind: String
  }
};
</script>

