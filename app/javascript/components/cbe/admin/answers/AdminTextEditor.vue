<template>
  <section class="box-item">
    <h6>Create text answer</h6>

    <div class="row pt-4">
      <div class="col-sm-12">
        <TinyEditor :fieldModel.sync="answer" />
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
import TinyEditor from "../../../TinyEditor";

export default {
  components: {
    TinyEditor
  },
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
        kind: "open",
        content: {
          text: newValue
        }
      };
    }
  }
};
</script>
