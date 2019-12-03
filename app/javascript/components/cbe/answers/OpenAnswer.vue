<template>
  <section>
    <div class="answers">
      <TinyEditor
        :field-model.sync="question"
        :aditional-toolbar-options="[]"
        @blur="$v.question.$touch()"
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
    questionId: {
      type: Number,
      default: null,
    }
  },
  data() {
    return {
      question: this.getPickedValue(),
    };
  },
  watch: {
    question(newValue) {
      this.$store.dispatch("userCbe/recordAnswer", {
        id: this.questionId,
        score: 0,
        correct: null,
        cbe_question_id: this.questionId,
        answers_attributes: [{
          content: {
            text: newValue,
          },
        }]
      });
    }
  },
  methods: {
    getPickedValue() {
      const initialValue = this.$store.state.userCbe.user_cbe_data.questions[
        this.questionId
      ];
      if (initialValue != null) {
        return initialValue.answers_attributes[0].content.text;
      }
        return "";

    }
  }
};
</script>
