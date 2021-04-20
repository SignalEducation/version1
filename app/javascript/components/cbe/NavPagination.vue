<template>
  <section class="overflow-auto">
    <b-pagination-nav
      :limit="pageLimit"
      :link-gen="linkGen"
      :number-of-pages="links.length"
      :hide-goto-end-buttons="true"
      align="right"
      use-router
    >
      <template v-slot:prev-text>
        <span class="arrow-left-icon">Previous</span>
      </template>
      <template v-slot:next-text>
        <span class="arrow-right-icon">Next</span>
      </template>
      <template v-slot:page>
        <CbeNavigator :cbe-id="link_data.id" />
      </template>
    </b-pagination-nav>
  </section>
</template>

<script>
import axios from 'axios';
import CbeNavigator from './CbeNavigator.vue'
import eventBus from "./EventBus.vue";
import { mapGetters } from 'vuex';

export default {
  components: {
    CbeNavigator
  },
  computed: {
    links: function () {
      return this.generateObjectLinks();
    },
    ...mapGetters('userCbe', {
      userCbeData: 'userCbeData',
    }),
  },
  data() {
    return {
      pageLimit: 0,
    };
  },
  props: {
    link_data: {},
    modalStatus: null,
  },
  watch: {
    $route(to, from) {
      if (to.name === 'introduction_pages') {
        this.pageLimit = 0;
      } else if (to.name === 'review') {
        this.pageLimit = 0;
      } else if (to.name === 'exam_submited') {
        this.pageLimit = 0;
      } else {
        this.pageLimit = 1;
        this.updateCurrentState(to.path);
      }

      this.updateAnswersData(from.name);
    },
  },
  methods: {
    linkGen(pageNum, object) {
      return this.links[pageNum - 1];
    },
    generateObjectLinks(){
      var object_link = [];

      object_link = this.mapObject(object_link, this.link_data.introduction_pages, 'introduction_pages')
      object_link = this.mapObject(object_link, this.link_data.sections, 'sections')
      object_link.push({ name: 'review', params: { cbe_id: this.link_data.id } })

      return object_link;
    },
    mapObject(object_link, object, type){
      if (object != null){
        object.filter(item => {
          switch(type) {
            case 'sections':
              object_link.push({ name: type, params: { id: item.id } })
              if (item.kind == 'exhibits_scenario') {
                item.scenarios.filter(scenario => {
                  object_link.push({ name: 'scenarios', params: { id: scenario.id } })
                });
              } else {
                item.questions.filter(question => {
                  object_link.push({ name: 'questions', params: { id: question.id } })
                });
              }
              break;
            default:
              object_link.push({ name: type, params: { id: item.id } })
          }
        });
      }

      return object_link
    },
    updateNavModal(value) {
      this.$emit("update-close-all", value);
    },
    updateCurrentState(current_state) {
      const data   = {};
      data.current_state  = current_state;

      if(this.userCbeData.cbe_id !== null){
        axios
          .post(
            `/api/v1/cbes/${this.userCbeData.cbe_id}/users_log/${this.userCbeData.user_log_id}/current_state`,
            {
              id: this.userCbeData.user_log_id,
              cbe_user_log: data,
            }
          )
          .then((response) => {
            // this.userCbeData.current_state = current_state;
          })
          .catch((error) => {});
      }
    },
    updateAnswersData(from) {
      if (from === 'questions') {
        eventBus.$emit("update-question-answer");
      }
    },
    toggleResetModal() {
      this.agreementModalIsOpen = !this.agreementModalIsOpen;
    },
  }
};
</script>
