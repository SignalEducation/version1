<template>
  <section class="cbe-section">
    <NavBar v-bind:logo="'CBE'" v-bind:title="cbe_data.title"/>

    <div class="cbe-content panel panel-default">
      <router-view :id="$route.path" />
    </div>

    <footer class="cbe-footer">
      <div class="container">
        <NavPagination v-bind:links="generateObjectLinks(cbe_data)" />
      </div>
    </footer>
  </section>
</template>

<script>
import NavBar from './NavBar';
import NavPagination from './NavPagination';
import { mapGetters } from 'vuex';

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
    // TODO(Giordano), Move these methods to NavPagination component.
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
