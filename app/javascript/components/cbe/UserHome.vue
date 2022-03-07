<template>
  <section id="student-cbe" class="cbe-section">
    <NavBar
      class="cbe-content-navbar"
      :logo="cbe_data.name"
      :title="cbe_data.name"
      :user-cbe-data="user_cbe_data"
      @update-close-all="modalsStatus($event)"
    />

    <div class="cbe-content">
      <router-view
        :id="$route.path"
        @update-close-all="exhModalStatus = $event"
      />
    </div>

    <div id="cbe-footer">
      <footer>
        <b-navbar class="nav nav-underline bg-cbe-gray">
          <b-navbar-nav>
            <CbeResources
              v-if="
                ['sections', 'questions', 'scenarios'].includes(
                  this.$route.name
                )
              "
              :cbe_data="cbe_data"
            />
          </b-navbar-nav>
          <b-navbar-nav
            v-if="
              $route.name == 'review' &&
                user_cbe_data.status !== 'corrected' &&
                user_cbe_data.status !== 'finished'
            "
          >
            <b-nav-text class="arrow-right-icon" @click="submitExam"
              >End Exam</b-nav-text
            >
          </b-navbar-nav>
          <b-navbar-nav>
            <NavPagination
              :link_data="cbe_data"
              :modal-status="navModalStatus"
              @update-close-all="navModalStatus = $event"
            />
          </b-navbar-nav>
        </b-navbar>
      </footer>
    </div>
  </section>
</template>

<script>
import axios from "axios";
import { mapGetters } from "vuex";
import CbeResources from "./CbeResources.vue";
import eventBus from "./EventBus.vue";
import NavBar from "./NavBar.vue";
import NavPagination from "./NavPagination.vue";

export default {
  components: {
    CbeResources,
    eventBus,
    NavBar,
    NavPagination,
  },
  data() {
    return {
      cbe_id: this.$parent.cbe_id,
      userId: this.$parent.user_id,
      exerciseId: this.$parent.exercise_id,
      exhModalStatus: null,
      navModalStatus: null,
    };
  },
  computed: {
    ...mapGetters("cbe", {
      cbe_data: "cbe_data",
    }),
    ...mapGetters("userCbe", {
      user_cbe_data: "userCbeData",
    }),
  },
  created() {
    eventBus.$on("update-question-answer", () => {
      this.submitUnfinishedExam();
    });
  },
  watch: {
    cbe_data: {
      handler() {
        this.$store.dispatch("userCbe/startUserCbeData", {
          cbe_id: this.cbe_id,
          user_id: this.userId,
          exercise_id: this.exerciseId,
          cbe_data: this.cbe_data,
        });

        this.createUserLog();
      },
    },
    "user_cbe_data.exam_pages": {
      handler() {
        this.submitUnfinishedExam();
      },
      deep: true,
    },
    $route(to) {
      this.updateExamPageState(to);
    },
  },
  mounted() {
    this.$store.dispatch("cbe/getCbe", this.cbe_id);
  },
  methods: {
    createUserLog() {
      const data = {};
      data.cbe_id = this.user_cbe_data.cbe_id;
      data.user_id = this.user_cbe_data.user_id;
      data.exercise_id = this.user_cbe_data.exercise_id;

      axios
        .post(`/api/v1/cbes/${this.user_cbe_data.cbe_id}/users_log`, {
          cbe_user_log: data,
        })
        .then((response) => {
          this.$store.dispatch("userCbe/recordUserLog", response.data);
          this.$router.push(response.data.current_state);
        })
        .catch((error) => {
          console.log(error);
        });
    },
    submitUnfinishedExam() {
      let data = this.formatedData();
      data.status = "started";

      axios
        .patch(
          `/api/v1/cbes/${this.cbe_id}/users_log/${this.user_cbe_data.user_log_id}`,
          {
            cbe_user_log: data,
          }
        )
        .then((response) => {
          //console.log("Unfinished saved.");
        })
        .catch((error) => {});
    },
    submitExam() {
      this.loader = this.$loading.show({
        loader: "dots",
        color: "#00b67B",
        container: this.fullPage ? null : this.$refs.formContainer,
      });

      let data = this.formatedData();
      data.status = "finished";

      axios
        .patch(
          `/api/v1/cbes/${this.cbe_id}/users_log/${this.user_cbe_data.user_log_id}`,
          {
            cbe_user_log: data,
          }
        )
        .then((response) => {
          window.location.href = `/exercises/${this.exerciseId}`;
        })
        .catch((error) => {});
    },
    formatedData() {
      const data = {};
      const questions = Object.values(this.user_cbe_data.questions);
      const responses = Object.values(this.user_cbe_data.responses);

      for (let i = 0; i < questions.length; i++) {
        delete questions[i].id;
      }

      for (let i = 0; i < responses.length; i++) {
        delete responses[i].id;
      }

      data.cbe_id = this.user_cbe_data.cbe_id;
      data.user_id = this.user_cbe_data.user_id;
      data.scratch_pad = this.user_cbe_data.scratch_pad;
      data.pages_state = this.user_cbe_data.exam_pages;
      data.exercise_id = this.user_cbe_data.exercise_id;
      data.questions_attributes = [].concat.apply([], questions);
      data.responses_attributes = [].concat.apply([], responses);
      return data;
    },
    updateExamPageState(route) {
      if (
        route.name === "sections" ||
        route.name === "scenarios" ||
        route.name === "questions"
      ) {
        const { id } = route.params;

        this.user_cbe_data.exam_pages.forEach((page) => {
          if (page.param === id && page.state === "Unseen") {
            page.state = "Seen";
          }
        });
      }
    },
    modalsStatus(status) {
      this.exhModalStatus = status;
      this.navModalStatus = status;
    },
  },
};
</script>
