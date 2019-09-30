<template>
  <section>
    <div
      class="questions"
      v-for="question in cbe_data.questions"
      v-if="question.id == id"
      :key="question.id"
    >
      <splitpanes class="default-theme" style="height: 460px">
        <span v-if="question.scenario != null" v-html="question.scenario.content"></span>
        <span>
          <section v-html="question.content" />

          <QuestionAnswers
            :answers="question.answers"
            :question_id="question.id"
            :question_kind="question.kind"
          />
        </span>
      </splitpanes>
    </div>
  </section>
</template>

<script>
import { mapGetters } from "vuex";
import Splitpanes from "splitpanes";
import QuestionAnswers from "../../components/cbe/QuestionAnswers";

export default {
  components: {
    Splitpanes,
    QuestionAnswers
  },
  props: {
    id: Number
  },
  computed: {
    ...mapGetters("cbe", {
      cbe_data: "cbeData"
    })
  }
};
</script>

