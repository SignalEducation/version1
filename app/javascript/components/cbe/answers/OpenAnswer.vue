<template>
  <section>
    <div class="answers">
      <TinyEditor
        :field-model.sync="question"
        :aditional-toolbar-options="[]"
        :editor-height="520"
        @blur="$v.question.$touch()"
      />
    </div>
  </section>
</template>
<script>
import EventBus from "../EventBus.vue";
import TinyEditor from "../../TinyEditor.vue";

export default {
  components: {
    EventBus,
    TinyEditor,
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
      let data = {
        id: this.questionId,
        score: 0,
        correct: null,
        cbe_question_id: this.questionId,
        answers_attributes: [{
          content: {
            text: newValue,
          },
        }]
      }

      EventBus.$emit("update-question-answer", data);
      this.$store.dispatch("userCbe/recordAnswer", data);
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
