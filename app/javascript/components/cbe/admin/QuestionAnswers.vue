<template>
  <section>
    <hr>
    <div class="panel-body no-top-padding">
      <p
        v-if="!validateData.questionAnswers.answersRequired"
        class="error-message"
      >
        You need to add answers to be able to save a question.
      </p>

      <p
        v-if="!validateData.questionAnswers.setCorrectAnswerRequired"
        class="error-message"
      >
        You need to set a correct answer to save a question.
      </p>
      <div class="row">
        <div class="col-sm-12 mb-2">
          <AdminDropdownList
            v-if="questionKind == 'dropdown_list'"
            :answers-array="answers"
            :question-id="questionId"
          />
          <AdminFillTheBlank
            v-if="questionKind == 'fill_in_the_blank'"
            :answers-array="answers"
            :question-id="questionId"
          />
          <AdminMultipleChoice
            v-if="questionKind == 'multiple_choice'"
            :answers-array="answers"
            :question-id="questionId"
          />
          <AdminMultipleResponse
            v-if="questionKind == 'multiple_response'"
            :answers-array="answers"
            :question-id="questionId"
          />
          <AdminSpreadsheet
            v-if="questionKind == 'spreadsheet'"
            :answers-array="answers"
            :question-id="questionId"
          />
          <!-- Let this commented for now, in future education team can
               use a pre formatted content in open questions -->
          <!-- <AdminTextEditor
            :answersArray="answers"
            :questionId="questionId"
            v-if="questionKind == 'open'"
          /> -->
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import AdminDropdownList from './answers/AdminDropdownList.vue';
import AdminFillTheBlank from './answers/AdminFillTheBlank.vue';
import AdminMultipleChoice from './answers/AdminMultipleChoice.vue';
import AdminMultipleResponse from './answers/AdminMultipleResponse.vue';
// import AdminTextEditor from './answers/AdminTextEditor.vue';
import AdminSpreadsheet from './answers/AdminSpreadsheet.vue';

export default {
  components: {
    AdminDropdownList,
    AdminFillTheBlank,
    AdminMultipleChoice,
    AdminMultipleResponse,
    // AdminTextEditor,
    AdminSpreadsheet,
  },
  props: {
    answers: {
      type: Array,
      default: () => [],
    },
    validateData: {
      type: Object,
      default: null,
    },
    questionId: {
      type: Number,
      default: null,
    },
    questionKind: {
      type: String,
      default: '',
    },
  },
};
</script>
