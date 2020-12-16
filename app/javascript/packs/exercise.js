import Vue from 'vue';
import OpenAnswers from '../components/exercises/OpenAnswers.vue';
import Appsignal from "@appsignal/javascript";
import { errorHandler } from "@appsignal/vue";

const appsignal = new Appsignal({
  key: "0f61ecea-6bab-48d4-aef5-e97718468d68",
});

Vue.config.errorHandler = errorHandler(appsignal, Vue);

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
