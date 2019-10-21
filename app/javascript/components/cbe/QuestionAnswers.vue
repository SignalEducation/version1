<template>
  <section>
    <DropdownList
      v-if="question_kind === 'dropdown_list'"
      :answers="answers"
      :question_id="question_id"
    />
    <!-- passing just the first answer in fill the blank cause is just one text value -->
    <FillTheBlank
      v-if="question_kind === 'fill_in_the_blank'"
      :answer="answers[0]"
      :question_id="question_id"
    />
    <MultipleChoice
      v-if="question_kind === 'multiple_choice'"
      :answers="answers"
      :question_id="question_id"
    />
    <MultipleResponse
      v-if="question_kind === 'multiple_response'"
      :answers="answers"
      :question_id="question_id"
    />
    <OpenAnswer
      v-if="question_kind === 'open'"
      :question_id="question_id"
    />
    <SpreadsheetAnswer
      v-if="question_kind === 'spreadsheet'"
      :question-id="question_id"
      :answer-data="answers[0]"
    />
  </section>
</template>

<script>
import DropdownList from './answers/DropdownList.vue';
import FillTheBlank from './answers/FillTheBlank.vue';
import MultipleChoice from './answers/MultipleChoice.vue';
import MultipleResponse from './answers/MultipleResponse.vue';
import OpenAnswer from './answers/OpenAnswer.vue';
import SpreadsheetAnswer from './answers/SpreadsheetAnswer.vue';

export default {
  components: {
    DropdownList,
    FillTheBlank,
    MultipleChoice,
    MultipleResponse,
    OpenAnswer,
    SpreadsheetAnswer,
  },
  props: {
    answers: {},
    question_id: Number,
    question_kind: String,
  },
};
</script>
