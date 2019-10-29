<template>
  <section>
    <div v-if="questionKind === 'dropdown_list'">
      <DropdownList
        :answers-data="answersData"
        :question-id="questionId"
        :question-score="questionScore"
      />
    </div>
    <div v-else-if="questionKind === 'fill_in_the_blank'">
      <FillTheBlank
        :answer-data="answersData[0]"
        :question-id="questionId"
        :question-score="questionScore"
      />
    </div>
    <div v-else-if="questionKind === 'multiple_choice'">
      <!-- passing only the first answer in fill the blank cause is just one text value -->
      <MultipleChoice
        :answers-data="answersData"
        :question-id="questionId"
        :question-score="questionScore"
      />
    </div>
    <div v-else-if="questionKind === 'multiple_response'">
      <MultipleResponse
        :answers-data="answersData"
        :question-id="questionId"
        :question-score="questionScore"
      />
    </div>
    <div v-else-if="questionKind === 'open'">
      <OpenAnswer :question-id="questionId" />
    </div>
    <div v-else-if="questionKind === 'spreadsheet'">
      <SpreadsheetAnswer
        :question-id="questionId"
        :answer-data="answersData[0]"
      />
    </div>
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
    answersData: {
      type: Array,
      required: true,
    },
    questionId: {
      type: Number,
      required: true,
    },
    questionKind: {
      type: String,
      required: true,
    },
    questionScore: {
      type: Number,
      required: false,
      default: null,
    },
  },
};
</script>
