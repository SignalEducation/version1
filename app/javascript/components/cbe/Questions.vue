<template>
  <section>
    <!-- TODO(Giordano), Find a way to pass just the specific page object instead check in a v-for. -->
    <div
      class="questions"
      v-for="question in cbe_data.questions"
      v-if="question.id == id"
      :key="question.id"
    >
      <div class="header">
        <h1>Question - {{ question.id }}</h1>
        <h3>{{ question.kind }}</h3>
      </div>

      <div class="content">
        <p>{{ question.content }}</p>
      </div>

      <hr />

      <div v-if="question.scenario != null" class="scenario">
        <h1>{{ question.scenario.content }}</h1>
      </div>
    </div>
  </section>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  props: {
    id: {
      // required: true,
      // type: Number
    }
  },
  computed: {
    ...mapGetters("cbe", {
      cbe_data: "cbeData"
    })
  }
};
</script>
