<template>
  <section>
    <div class="answers">
      <TinyEditor
        @blur="$v.question.$touch()"
        :fieldModel.sync="question"
        :aditionalToolbarOptions="[]"
      />
    </div>
  </section>
</template>
<script>
import TinyEditor from "../../TinyEditor.vue";

export default {
  components: {
    TinyEditor
  },
  props: {
    questionId: Number
  },
  data() {
    return {
      question: this.getPickedValue(),
    };
  },
  watch: {
    question(newValue) {
      this.$store.dispatch("userCbe/recordAnswer", {
        id: this.question_id,
        answers: {
          content: {
            text: newValue
          },
          cbe_question_id: this.questionId
        }
      });
    }
  },
  methods: {
    getPickedValue() {
      var initial_value = this.$store.state.userCbe.user_cbe_data.questions[
        this.questionId
      ];
      if (initial_value != null) {
        return initial_value;
      } else {
        return "";
      }
    }
  }
};
</script>
