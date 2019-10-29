<template>
  <section
    id="student-cbe"
    class="cbe-section"
  >
    <NavBar
      :logo="cbe_data.name"
      :title="cbe_data.name"
      :user_cbe_data="user_cbe_data"
    />

    <div class="cbe-content">
      <router-view :id="$route.path" />
      <CbeCalculator />
    </div>

    <div id="cbe-footer">
      <footer>
        <b-navbar class="nav nav-underline bg-cbe-gray">
          <b-navbar-nav>
            <b-nav-text
              v-if="['sections', 'questions'].includes(this.$route.name)"
              class="help-icon"
            >
              Help
            </b-nav-text>
          </b-navbar-nav>
          <b-navbar-nav v-if="$route.name == 'review'">
            <b-nav-text
              class="arrow-right-icon"
              @click="submitExam"
            >
              End Exam
            </b-nav-text>
          </b-navbar-nav>
          <b-navbar-nav>
            <NavPagination :link_data="cbe_data" />
          </b-navbar-nav>
        </b-navbar>
      </footer>
    </div>
  </section>
</template>

<script>
import axios from 'axios';
import { mapGetters } from 'vuex';
import CbeCalculator from '../cbe/CbeCalculator.vue';
import NavBar from './NavBar.vue';
import NavPagination from './NavPagination.vue';

export default {
  components: {
    CbeCalculator,
    NavBar,
    NavPagination,
  },
  data() {
    return {
      cbe_id: this.$parent.cbe_id,
      userId: this.$parent.user_id,
      exerciseId: this.$parent.exercise_id,
    };
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbe_data',
    }),
    ...mapGetters('userCbe', {
      user_cbe_data: 'userCbeData',
    }),
  },
  watch: {
    cbe_data: {
      handler() {
        this.$store.dispatch('userCbe/startUserCbeData', {
          cbe_id: this.cbe_id,
          user_id: this.userId,
          exercise_id: this.exerciseId,
          cbe_data: this.cbe_data,
        });
      },
    },
    $route(to) {
      this.updateExamPageState(to);
    },
  },
  mounted() {
    this.$store.dispatch('cbe/getCbe', this.cbe_id);
  },
  methods: {
    submitExam() {
      axios
        .patch(
          `/api/v1/cbes/${this.cbe_id}/users_log/${this.user_cbe_data.user_log_id}`,
          {
            cbe_user_log: this.formatedData(),
          }
        )
        .then(response => {
          window.location.href = `/en/exercises/${this.exerciseId}`;
        })
        .catch(error => {});
    },
    formatedData() {
      const data = {};
      const questions = Object.values(this.user_cbe_data.questions);
      const answers = questions.map(a => a.answers);

      const score = questions
        .map(a => a.score)
        .filter(Number)
        .reduce((a, b) => a + b, 0);

      data.status = 'finished';
      data.score = score;
      data.cbe_id = this.user_cbe_data.cbe_id;
      data.user_id = this.user_cbe_data.user_id;
      data.exercise_id = this.user_cbe_data.exercise_id;
      data.answers_attributes = [].concat.apply([], answers);
      return data;
    },
    updateExamPageState(route) {
      if (route.name === 'sections' || route.name === 'questions') {
        const {id} = route.params;

        this.user_cbe_data.exam_pages.forEach(page => {
          if ( page.type === 'questions' &&
               page.param === id &&
               page.state === 'Unseen' ) {
            page.state = 'Seen';
          }
        });
      }
    },
  },
};
</script>
