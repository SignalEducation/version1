<template>
  <section>
    <hr />
    <div class="panel-body no-top-padding">
      <div class="row">
        <div class="col-sm-12 mb-2">
          <AdminDropdownList
            :answersArray="answers"
            :question_id="question_id"
            v-if="question_kind == 'dropdown_list'"
          />
          <AdminFillTheBlank
            :answersArray="answers"
            :question_id="question_id"
            v-if="question_kind == 'fill_in_the_blank'"
          />
          <AdminMultipleChoice
            :answersArray="answers"
            :question_id="question_id"
            v-if="question_kind == 'multiple_choice'"
          />
          <AdminMultipleResponse
            v-if="question_kind == 'multiple_response'"
            :answersArray="answers"
            :question_id="question_id"
          />
          <AdminSpreadsheet
            v-if="question_kind == 'spreadsheet'"
            :answersArray="answers"
            :questionId="question_id"
          />
          <!-- Let this commented for now, in future education team can
               use a pre formatted content in open questions -->
          <!-- <AdminTextEditor
            :answersArray="answers"
            :question_id="question_id"
            v-if="question_kind == 'open'"
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
import AdminTextEditor from './answers/AdminTextEditor.vue';
import AdminSpreadsheet from './answers/AdminSpreadsheet.vue';

export default {
  components: {
    AdminDropdownList,
    AdminFillTheBlank,
    AdminMultipleChoice,
    AdminMultipleResponse,
    AdminTextEditor,
    AdminSpreadsheet,
  },
  props: {
    answers: Array,
    question_id: Number,
    question_kind: String,
  },
};
</script>
