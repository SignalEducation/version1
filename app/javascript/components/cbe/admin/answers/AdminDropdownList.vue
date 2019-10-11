<template>
  <section class="box-item">
    <h6>Create a dropdown list</h6>

    <div class="row pt-4">
      <div class="col-sm-12">
        <form v-on:submit.prevent="addAnswer">
          <!-- TODO(Giordano), duplicated code here
               find a way to change just classes instead to repeat all block again -->
          <div v-if="!$v.answer.required || !$v.answer.isUnique">
            <input v-model="answer" class="form-control answers-input" placeholder="Add the answer text here..." />
            <button class="btn button" type="submit" disabled="true">
              <i class="glyphicon glyphicon-plus"></i>
            </button>
          </div>
          <div v-else>
            <input v-model="answer" class="form-control answers-input" placeholder="Add the answer text here..." />
            <button class="btn btn-secondary button" type="submit">
              <i class="glyphicon glyphicon-plus"></i>
            </button>
          </div>

          <div class="error-message" v-if="!$v.answer.isUnique">This answer is already registered.</div>
        </form>
      </div>
    </div>

    <div class="row pt-4">
      <div class="col-sm-12">
        <draggable tag="ul" :answers="answersArray" class="list-group" handle=".handle">
          <div class="list-group-item answer-list" v-for="(element, idx) in answersArray" :key="element.id">
            <i class="fa fa-times close" @click="removeAt(idx)"></i>

            <div class="input-group">
              <div class="input-group-prepend">
                <div class="input-group-text">
                  <i class="glyphicon glyphicon-sort handle" title="Drag to reorder"></i>
                </div>
                <label class="input-group-text">
                  <input type="radio" class="" name="answers" v-on:click="updateAnswer(idx)" :checked="element.content.correct" />
                </label>
              </div>
              <input type="text" :placeholder="element.content.text" class="answers-text-input" />
            </div>
          </div>
        </draggable>
      </div>
    </div>
  </section>
</template>

<script>
import draggable from "vuedraggable";
import { validationMixin } from "vuelidate";
import { required } from "vuelidate/lib/validators";

export default {
  components: {
    draggable
  },
  props: {
    answersArray: Array,
  },
  mixins: [validationMixin],
  data() {
    return {
      id: 0,
      answer: ""
    }
  },
  validations: {
    answer: {
      required,
      isUnique (value) {
        let check = true;
        this.answersArray.filter(answer => {
          if (answer.content.text == value) check = false;
        });

        return check
      }
    }
  },
  watch: {
    answersArray(newValue, oldValue) {
      console.log(oldValue);
      console.log(newValue);
    }
  },
  methods: {
    removeAt(idx) {
      this.answersArray.splice(idx, 1);
    },
    addAnswer: function() {
      this.id++;
      this.answersArray.push({
        kind: "dropdown_list",
        content: {
          text: this.answer,
          correct: false
        }
      });
      this.answer = "";
    },
    // TODO(Giordano), I've to created a method to update content in answers data.
    // could have a better option to do it geeting from form and using v-bind.
    updateAnswer(idx) {
      this.answersArray.forEach(function(answer, index) {
        this[index].content.correct = false;
      }, this.answersArray);

      this.answersArray[idx].content.correct = true;
    }
  }
};
</script>
