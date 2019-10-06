<template>
  <section>
    <h3>Item Review Screen</h3>

    <b-table
      striped
      hover
      :items="user_cbe_data.exam_pages"
      :fields="[{ key: 'description', label: 'Question #' }, { key: 'state', label: 'Status' }, { key: 'flagged', label: 'Flagged - Review' }]"
    >
    </b-table>

    <div id="example-1">
      <button v-on:click="submitExam">End Exam</button>
    </div>
  </section>
</template>

<script>
import axios from "axios";
import { mapGetters } from "vuex";

export default {
  props: {
    cbe_id: Number
  },
  computed: {
    ...mapGetters("userCbe", {
      user_cbe_data: "userCbeData"
    })
  },
  methods: {
    submitExam: function() {
      axios
        .post(`/api/v1/cbes/${this.cbe_id}/users_log`, {
          cbe_user_log: this.formatedData()
        })
        .then(response => {
          window.location.href = `/api/v1/cbes/${this.cbe_id}/users_log/${response.data.id}`;
        })
        .catch(error => {});
    },

    formatedData: function() {
      let data = {};
      // get questions from user_cbe_data and map those answers in a array.
      // concat in a kind of flatten in that array.
      let answers = [].concat.apply(
        [],
        Object.values(this.user_cbe_data.questions).map(a => a.answers)
      );
      data.status = "finished";
      data.score = 100;
      data.cbe_id = this.user_cbe_data.cbe_id;
      data.user_id = this.user_cbe_data.user_id;
      data.answers_attributes = answers;
      return data;
    }
  }
};
</script>
