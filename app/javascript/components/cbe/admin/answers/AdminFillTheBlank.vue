<template>
  <section class="box-item">
    <h6>Create fill in the blank answer</h6>

    <div class="row pt-4">
      <div class="col-sm-12">
        <input
          v-model="answer"
          class="form-control answers-input"
          placeholder="Add the answer text here..."
        />
        <div class="error-message" v-if="!$v.answer.required">
          This answer is required.
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import { validationMixin } from "vuelidate";
import { required } from "vuelidate/lib/validators";

export default {
  props: {
    answersArray: Array
  },
  mixins: [validationMixin],
  data() {
    return {
      id: 0,
      answer: ""
    };
  },
  validations: {
    answer: {
      required
    }
  },
  watch: {
    answer(newValue, oldValue) {
      this.answersArray[0] = {
        kind: "fill_in_the_blank",
        content: {
          text: newValue
        }
      };
    }
  }
};
</script>
