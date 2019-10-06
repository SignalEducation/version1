<template>
  <section>
    <hr />

    <div class="panel-body no-top-padding">
      <div class="row">
        <div class="col-sm-12 mb-2">
          <AdminMultipleChoice
            :answersArray="answers"
            :question_id="question_id"
            v-if="question_kind == 'multiple_choice'"
          />
          <AdminMultipleResponse
            :answersArray="answers"
            :question_id="question_id"
            v-if="question_kind == 'multiple_response'"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import AdminMultipleChoice from "./answers/AdminMultipleChoice";
import AdminMultipleResponse from "./answers/AdminMultipleResponse";

export default {
  components: {
    AdminMultipleChoice,
    AdminMultipleResponse
  },
  props: {
    answers: Array,
    question_id: Number,
    question_kind: String
  }
};
</script>

