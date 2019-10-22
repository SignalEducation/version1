<template>
  <section class="overflow-auto">
    <b-pagination-nav
      :limit="1"
      :link-gen="linkGen"
      :number-of-pages="links.length"
      :hide-goto-end-buttons="true"
      align="right"
      use-router
    >
      <template v-slot:prev-text><span class="arrow-left-icon">Previous</span></template>
      <template v-slot:next-text><span class="arrow-right-icon">Next</span></template>
      <template v-slot:page><CbeNavigator v-bind:cbeId="link_data.id" /></template>
    </b-pagination-nav>
  </section>
</template>

<script>
import CbeNavigator from "../CbeNavigator"

export default {
  components: {
    CbeNavigator
  },
  computed: {
    links: function () {
      return this.generateObjectLinks();
    }
  },
  props: {
    link_data: {}
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
