<template>
  <section class="overflow-auto">
    <b-pagination-nav
      :limit="1"
      :link-gen="linkGen"
      :number-of-pages="links.length"
      :hide-goto-end-buttons="true"
      prev-text="Previous"
      next-text="Next"
      use-router
    ></b-pagination-nav>
  </section>
</template>

<script>
export default {
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
      object_link.push({ name: 'agreement' })
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
