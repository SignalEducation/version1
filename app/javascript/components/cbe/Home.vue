<template>
  <section class="cbe-section" id="student-cbe">
    <NavBar :logo="cbe_data.name" :title="cbe_data.name" :user_cbe_data="user_cbe_data" />

    <div class="cbe-content">
      <router-view :id="$route.path" />
    </div>

    <div id="cbe-footer">
      <footer>
        <b-navbar class="nav nav-underline bg-cbe-gray">
          <b-navbar-nav v-if="$route.name != 'review'">
            <b-nav-text class="help-icon">Help</b-nav-text>
          </b-navbar-nav>
          <b-navbar-nav v-if="$route.name == 'review'">
            <b-nav-text class="arrow-right-icon" v-on:click="submitExam">End Exam</b-nav-text>
          </b-navbar-nav>
          <b-navbar-nav>
            <NavPagination v-bind:link_data="cbe_data" />
          </b-navbar-nav>
        </b-navbar>
      </footer>
    </div>
  </section>
</template>

<script>
import axios from 'axios';
import { mapGetters } from 'vuex';
import NavBar from './NavBar.vue';
import NavPagination from './NavPagination.vue';

export default {
  components: {
    NavBar,
    NavPagination,
  },
  data() {
    return {
      cbe_id: this.$parent.cbe_id,
      userId: this.$parent.user_id,
    };
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbe_data',
    }),
    ...mapGetters('user_cbe', {
      user_cbe_data: 'user_cbe_data',
    }),
  },
  watch: {
    cbe_data: {
      handler() {
        this.$store.dispatch('user_cbe/startUserCbeData', {
          cbe_id: this.cbe_id,
          user_id: this.userId,
          cbe_data: this.cbe_data,
        });
      }
    },
    '$route': {
      handler: function(route) {
        if (route.name === 'sections' || route.name === 'questions') {
          this.updateExamPageState(route)
        }
      },
    }
  },
  mounted() {
    this.$store.dispatch('cbe/getCbe', this.cbe_id);
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
    },
    updateExamPageState: function(route) {
      let id = route.params.id;
      let type = route.name;

      this.user_cbe_data.exam_pages.forEach(page => {
        if (page.type == "questions" && page.param == id && page.state == 'Unseen') {
          page.state = "Seen";
        }
      });
    }
  },
};
</script>
