<template>
  <div id="resourceTabs">
    <PDFViewer
      :file-url="currentFile.url"
    />
    <div class="resource-tab-container">
      <div
        v-for="resource in files"
        :key="'resource-tab-' + resource.id"
        :class="['resource-tab', currentFile.id === resource.id ? 'active' : '']"
      >
        <a @click="chooseFile(resource.id)">
          {{ resource.title }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import PDFViewer from "../../lib/PDFViewer";

export default {
  components: {
    PDFViewer,
  },
  props: {
    files: {
      type: Array,
      default: () => [],
    },
    active: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      chosenFile: {},
    }
  },
  computed: {
    currentFile() {
      if (!this.active) return '';
      if (Object.keys(this.chosenFile).length > 0) {
        return this.chosenFile;
      }
      return this.files[0];
    },
  },
  watch: {
    active: function(newState, oldState) {
      if(newState === true) {
        this.chooseFile(this.files[0].id);
      }
    }
  },
  methods: {
    chooseFile(resourceId) {
      this.chosenFile = this.files.find(resource => resource.id === resourceId);
    },
  }
};
</script>

<style scoped>
  div.resource-tab-container {
    background-color: #efefef;
    padding-top: 3px;
  }
  div.resource-tab {
    background: #a7a7a7;
    display: inline-block;
    padding: 10px;
    margin-right: 7px;
    border-top-right-radius: 5px 5px;
  }
  div.resource-tab.active {
    background: #525f69;
  }
  div.resource-tab > a {
    cursor: pointer;
    color: white;
  }
</style>
