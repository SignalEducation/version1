import Vue from 'vue';
import Router from 'vue-router';
import Cbe from 'views/cbes/Cbe.vue';
import IntroductionPages from 'views/cbes/Introduction.vue';
import CbeAgreement from 'views/cbes/Agreement.vue';
import Sections from 'views/cbes/Sections.vue';
import Questions from 'views/cbes/Questions.vue';
import CbeReview from 'views/cbes/Review.vue';

Vue.use(Router);

export default new Router({
  mode: 'abstract',
  routes: [
    {
      path: '/introductions/:id',
      name: 'introduction_pages',
      component: IntroductionPages,
      props: true,
    },
    {
      path: '/agreement',
      name: 'agreement',
      component: CbeAgreement,
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
      props: true,
    },
    {
      path: '/review/:cbe_id',
      name: 'review',
      component: CbeReview,
      props: true,
    },
  ],
});
