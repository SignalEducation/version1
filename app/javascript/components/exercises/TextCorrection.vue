<template>
  <section>
    <TinyEditor
      :field-model.sync="questionContent"
      :aditional-toolbar-options="['fullscreen code']"
      :editor-id="editorId"
      @blur="$v.questionContent.$touch()"
    />
  </section>
</template>

<script>
import TinyEditor from '../TinyEditor.vue';

export default {
  components: {
    TinyEditor,
  },
  props: {
    questionContent: {
      type: String,
      default: "",
    },
    editorId:{
      type: Number,
      default: null,
    }
  },
};
</script>
