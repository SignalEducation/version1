<template>
  <section>
    <div class="aselect" :data-value="value" :data-list="previousAttempts">
      <div class="selector" @click="toggle()">
          <div class="label">
            <span>
              <i class="material-icons exhibits-icon">schedule</i>
              <p>{{ value.created }}</p>
            </span>
          </div>
      <div class="arrow" :class="{ expanded : visible }"></div>
          <div :class="{ hidden : !visible, visible }">
              <ul>
                <li :class="{ current : log === value }" :key="log.id" v-for="log in previousAttempts" @click="select(log)">
                  <i class="material-icons exhibits-icon">schedule</i>
                  <p>{{ log.created }}</p>
                </li>
              </ul>
          </div>
      </div>
    </div>
  </section>
</template>

<script>
function rightPaneScrolling() {
  let isScrolling;
  if (document.getElementById("rightPaneTopUnderline") != null) {
    if ($("#pane_1").scrollTop() == 0) {
      setTimeout(() => {
        document.getElementById("rightPaneTopUnderline").style.display = "none";
      }, 500);
    }
    document.getElementById("rightPaneTopUnderline").style.display = "block";
  }
  window.clearTimeout( isScrolling );
}

import axios from "axios";
import eventBus from "../cbe/EventBus.vue";

export default {
  components: {
    eventBus,
  },
  name: 'aselect',
  data() {
    return {
      value: { created: 'Previous Attempts' },
      visible: false
    };
  },
  props: {
    stepLogId: {
      type: [String, Number],
    },
    previousAttempts: {
      type: [Array, Object]
    },
  },
  methods: {
    updateCurrentResponse: function() {
      axios
        .patch(
          `/api/v1/course_step_log/${this.stepLogId}/practice_questions/${this.practiceQuestionId}`,
          {
            responses: this.responseContentArray,
          }
        )
        .then((response) => {
          console.log;
        })
        .catch((error) => {});
    },
    updateCourseStepLog: function(log_id) {
      eventBus.$emit("update-course_step-log", log_id);
    },
    toggle() {
      this.visible = !this.visible;
    },
    select(option) {
      this.value = option;
      this.updateCourseStepLog(option.id);
    }
  },
};
</script>
