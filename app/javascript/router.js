import Vue from 'vue';
import Router from 'vue-router';
import IntroductionPages from './views/cbes/Introduction.vue';
import Sections from './views/cbes/Sections.vue';
import ExhibitScenarios from './views/cbes/ExhibitScenarios.vue';
import Questions from './views/cbes/Questions.vue';
import CbeReview from './views/cbes/Review.vue';
import ExamSubmited from './views/cbes/ExamSubmited.vue';


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
      path: '/sections/:id',
      name: 'sections',
      component: Sections,
      props: true,
    },
    {
      path: '/scenarios/:id',
      name: 'scenarios',
      component: ExhibitScenarios,
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
    {
      path: '/exam_submited/',
      name: 'exam_submited',
      component: ExamSubmited,
    },
  ],
});
