import Vue               from 'vue';
import Router            from 'vue-router';
import Cbe               from 'views/cbe/Cbe.vue'
import IntroductionPages from 'views/cbe/Introduction.vue'
import Sections          from 'views/cbe/Sections.vue'
import Questions         from 'views/cbe/Questions.vue'

Vue.use(Router);

export default new Router({
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
