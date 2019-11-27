
<template>
  <div>
    <editor
      :id="editorId"
      v-model="localFieldModel"
      :api-key="apiKey"
      :init="{
        branding: false,
        menubar: false,
        statusbar: false,
        resize: false,
        toolbar: ['newdocument | \
                    cut copy paste | \
                    undo redo | \
                    searchreplace | \
                    bold italic underline strikethrough | \
                    subscript superscript | \
                    removeformat',
                  'formatselect | \
                    table | \
                    alignleft aligncenter alignright alignjustify | \
                    numlist bullist | \
                    outdent indent'].concat(aditionalToolbarOptions),
        plugins: 'fullscreen lists table code paste searchreplace',
        skin: 'custom'
      }"
      @input="$emit('update:fieldModel', localFieldModel)"
    />
  </div>
</template>

<script>
import Editor from "@tinymce/tinymce-vue";
import '../lib/TinyEditor/styles/custom/skin.min.css';
import '../lib/TinyEditor/styles/custom/content.min.css';

export default {
  components: {
    editor: Editor
  },
  props: {
    editorId: String,
    fieldModel: String,
    aditionalToolbarOptions: Array
  },
  data() {
    return {
      localFieldModel: this.fieldModel,
      apiKey: '6lr2e49pkvekjoocwhblfmatskmhek3h3ae8f4cbpfw3u3vw'
    };
  },
  watch: {
    localFieldModel(fieldModel) {
      this.$emit("update", fieldModel);
    },
    fieldModel: function () {
      if(this.fieldModel === null){
        tinymce.get(this.editorId).setContent('');
      }
    }
  },
  methods: {
    updateContent: function(data) {
      this.editor.value = "";
    },
  }
};
</script>
