<template>
  <section>
    <b-table
      striped
      hover
      :items="getExamsPage"
      :fields="fields"
    >
      <template v-slot:cell(description)="data">
        <router-link :to="{ name: data.item.type, params: { id: data.item.param }}">
          {{ data.item.description }}
        </router-link>
      </template>

      <template v-slot:cell(state)="data">
        <router-link :to="{ name: data.item.type, params: { id: data.item.param }}">
          {{ data.item.state }}
        </router-link>
      </template>
      <template v-slot:cell(flagged)="data">
        <CbeFlagToReview :user_cbe_data="user_cbe_data" :type="data.item.type" :flagId="data.item.param" />
      </template>
    </b-table>
  </section>
</template>

<script>
import { mapGetters } from "vuex";
import CbeFlagToReview from "../../components/cbe/CbeFlagToReview.vue"

export default {
  components: {
    CbeFlagToReview
  },
  props: {
    cbe_id: Number,
  },
  data() {
    return {
      fields: [
        { key: 'description', label: 'Question #' },
        { key: 'state', label: 'Status' },
        { key: 'flagged', label: 'Flagged - Review' },
      ],
    };
  },
  computed: {
    ...mapGetters('userCbe', {
      user_cbe_data: 'userCbeData',
    }),
    getExamsPage: function () {
      var examPage = this.user_cbe_data.exam_pages;
      if( Array.isArray(examPage) ) {
        return this.user_cbe_data.exam_pages;
      } else {
        return []
      }
    }
  },
};
</script>
