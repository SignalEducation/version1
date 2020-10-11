<template>
  <section>
    <div style="padding:15px;">
      <ul class="flex-container">
        <li style="margin-left:0"><LeftArrow /></li>
        <li class="flex-item">Question 1 of {{totalQuestions}}</li>
        <li style="margin-left:0"><RightArrow /></li>
      </ul>
        Live-edge forage leggings tofu shoreditch salvia palo santo organic iPhone. 90's kogi brunch tumblr, pork belly chartreuse sustainable. Hella subway tile plaid lomo health goth humblebrag cardigan umami 3 wolf moon pok pok truffaut. Chillwave franzen vinyl heirloom. Af venmo etsy, readymade iPhone pitchfork microdosing fashion axe austin +1 intelligentsia taxidermy. Raw denim leggings four loko yuccie put a bird on it seitan deep v.
    </div>
  </section>
</template>

<script>

import LeftArrow from './LeftArrow.vue';
import RightArrow from './RightArrow.vue';

export default {
  components: {
    LeftArrow,
    RightArrow,
  },
  props: {
  	totalQuestions: {
      type: Number,
  	},
  },
  data() {
    return {
      modalIsOpen: false,
    };
  },
  methods: {
    handleChange(value) {
      this.modalIsOpen = value
    },
    showNavOptions(permittedPages) {
      return permittedPages.includes(this.$route.name);
    }
  },
};
</script>