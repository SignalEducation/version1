<template>
  <div>
    <b-nav-text class="scratch-pad-icon" ref="myBtn" v-on:click="modalIsOpen = !modalIsOpen">Scratch Pad</b-nav-text>

    <div ref="myModal" class="modal" v-show="modalIsOpen">
      <div class="modal-content">
        <span class="modal-title">Scratch Pad</span>
        <span class="close" v-on:click="modalIsOpen = !modalIsOpen">&times; </span>
        <!-- I'm using editor here instead to use our TinyEditor component
             the reason is because our component already have some config
             that we don't need here. -->
        <!-- TODO(giordano), use our component here. -->
        <editor
          :api-key="this.apiKey"
          :init="{
            branding: false,
            menubar: false,
            statusbar: false,
            resize: false,
            toolbar: ['cut copy paste undo redo']
          }"
          v-model="user_cbe_data.scratch_pad"
        ></editor>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

import Editor from "@tinymce/tinymce-vue";

export default {
  components: {
    Editor
  },
  data() {
    return {
      apiKey: "6lr2e49pkvekjoocwhblfmatskmhek3h3ae8f4cbpfw3u3vw",
      modalIsOpen: false
    };
  },
  props: {
    user_cbe_data: Object
  },
  methods: {
    toggleScratch: function() {
      let type = this.route.name;
      let id = this.route.params.id;

      this.user_cbe_data.exam_pages.forEach(item => {
        if (item.type == type && item.param == id) {
          this.pageFlag = item.flagged;
        }
      });
    }
  }
};
</script>
