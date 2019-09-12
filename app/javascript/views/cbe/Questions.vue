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
        <span v-html="question.content"></span/>
      </splitpanes>
    </div>
  </section>
</template>

<script>
import { mapGetters } from "vuex";
import Splitpanes from 'splitpanes'

export default {
  components: { Splitpanes },
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

