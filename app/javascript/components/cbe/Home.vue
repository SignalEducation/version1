<template>
  <section>
    <NavBar />
    <NavPagination v-bind:links="generateObjectLinks(cbe_data)" />

    <router-view :id="$route.path" />
  </section>
</template>

<script>
import { mapGetters } from 'vuex';
import NavBar from './NavBar';
import NavPagination from './NavPagination';

export default {
  mounted() {
    this.$store.dispatch('cbe/getCbe', this.$parent.cbe_id);
  },
  computed: {
    ...mapGetters('cbe', {
      cbe_data: 'cbeData'
    })
  },
  components: {
    NavBar,
    NavPagination
  },
  methods: {
    generateObjectLinks(cbe_data){
      var object_link = []

      object_link.push({ name: 'cbe' })
      object_link = this.mapObject(object_link, cbe_data.introduction_pages, 'introduction_pages')
      object_link = this.mapObject(object_link, cbe_data.sections, 'sections')

      return object_link;
    },

    mapObject(object_link, object, type){
      if (object != null){
        object.filter(item => {
          switch(type) {
            case 'sections':
              object_link.push({ name: type, params: { id: item.id } })
              item.questions.filter(question => {
                object_link.push({ name: 'questions', params: { id: question.id } })
              });
              break;
            default:
              object_link.push({ name: type, params: { id: item.id } })
          }

        });
      }

      return object_link
    }
  }
};
</script>
