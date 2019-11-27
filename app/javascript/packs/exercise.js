import Vue from 'vue';
import OpenAnswers from '../components/exercises/OpenAnswers.vue';

document.addEventListener('DOMContentLoaded', () => {
  const openAnswers = document.getElementById('open-answers-component');
  if (openAnswers != null) {
    (() =>
      new Vue({
        el: openAnswers,
        data: {
          answerType: openAnswers.dataset.answerType,
          content: openAnswers.dataset.content,
          answerId: openAnswers.dataset.answerId,
          cbeId: openAnswers.dataset.cbeId,
          cbeUserLogId: openAnswers.dataset.cbeUserLogId,
        },
        render: h => h(OpenAnswers),
      }))();
  }
});
