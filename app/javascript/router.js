import Vue               from 'vue';
import Router            from 'vue-router';
import Cbe               from 'components/cbe/Cbe.vue'
import IntroductionPages from 'components/cbe/IntroductionPages.vue'
import Sections          from 'components/cbe/Sections.vue'
import Questions         from 'components/cbe/Questions.vue'

Vue.use(Router);

export default new Router({
  mode: 'abstract',
  routes: [
    {
      path: '/',
      name: 'cbe',
      component: Cbe,
    },
    {
      path: '/introductions/:id',
      name: 'introduction_pages',
      component: IntroductionPages,
      props: true
    },
    {
      path: '/sections/:id',
      name: 'sections',
      component: Sections,
      props: true,
    },
    {
      path: '/questions/:id',
      name: 'questions',
      component: Questions,
      props: true
    }
  ]
})
