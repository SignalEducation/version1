
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
        height: editorHeight,
        image_dimensions: true,
        toolbar: toolbarOptions(),
        plugins: 'fullscreen lists table code paste searchreplace image',
        images_upload_handler: imageUploadHandler,
        image_advtab: true,
        skin: 'custom',
      }"
      @input="$emit('update:fieldModel', localFieldModel)"
    />
  </div>
</template>

<script>
import axios from 'axios';
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
    aditionalToolbarOptions: Array,
    editorHeight: {
      type: Number,
      default: 300,
    }
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
    fieldModel() {
      if(this.fieldModel === null){
        tinymce.get(this.editorId).setContent('');
      }
    }
  },
  methods: {
    imageUploadHandler(blobInfo, uploadSuccess, uploadFailure) {
      const blob = blobInfo.blob();
      const filename = blobInfo.filename();
      axios({
            method: 'post',
            url: `/api/v1/uploads`,
            data: { upload: { filename } },
          })
            .then(response => {
              const {data} = response;
              axios({
                url: data.upload.url,
                method: 'PUT',
                headers: {
                  'Content-Type': data.content_type,
                  'Content-Encoding': 'base64'
                },
                data: blob,
              }).then(s3Response => {
                const {url} = s3Response.config
                uploadSuccess(url.split('?')[0]);
              })
            })
            .catch(error => {
              uploadFailure(error);
            });
    },
    toolbarOptions() {
      const toolbar = [
        'newdocument | cut copy paste | undo redo | searchreplace | bold italic underline strikethrough | subscript superscript | removeformat',
        'formatselect | table | alignleft aligncenter alignright alignjustify | numlist bullist | outdent indent'
      ]

      return toolbar.concat(this.aditionalToolbarOptions);
    },
    updateContent() {
      this.editor.value = "";
    },
  }
};
</script>
