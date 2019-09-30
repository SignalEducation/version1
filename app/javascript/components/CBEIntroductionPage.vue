<template>
  <b-tab :title="tabTitle">
    <div class="row ">
      <div class="col-sm-12">
        <div class="form-group">
          <label for="pageTitle">Title</label>
          <div class="input-group input-group-lg">
            <input v-model="title" placeholder="Title" class="form-control" id="pageTitle" />
          </div>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="pageKindSelect">Page Type</label>
          <b-form-select v-model="kind" :options="introPageKinds" id="pageKindSelect" class="input-group input-group-lg">
            <template slot="first">
              <option :value="null" disabled>-- Please select a type --</option>
            </template>
          </b-form-select>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="pageContent">Page Content</label>
          <TinyEditor
              :fieldModel.sync="content"
              :aditionalToolbarOptions="['fullscreen']"
              :editorId="'introPagesEditor' + id"
          />
        </div>
      </div>

      <div>
        <button v-if="id" v-on:click="updatePage" class="btn btn-primary">Update Page</button>
        <button v-else v-on:click="savePage" class="btn btn-primary">Save Page</button>
      </div>
    </div>
  </b-tab>
</template>

<script>
  import axios from "axios";
  import TinyEditor from "./TinyEditor";

  export default {
    components: {
      TinyEditor
    },
    props: {
      id: {
        type: Number,
        default: 0
      },
      initialTitle: {
        type: String,
        default: ''
      },
      initialContent: String,
      initialKind: String,
    },
    data: function() {
      return {
        pageDetails: {},
        title: this.initialTitle,
        content: this.initialContent,
        kind: this.initialKind,
        introPageKinds: [ 'text', 'agreement' ]
      };
    },
    computed: {
      tabTitle: function () {
        return this.title.length > 0 ? this.title : 'New Introduction Page'
      },
    },
    methods: {
      savePage: function() {
        this.pageDetails["title"]   = this.title;
        this.pageDetails["content"] = this.content;
        this.pageDetails["kind"]    = this.kind;
        this.pageDetails["cbe_id"]  = this.$store.state.cbeId;

        axios
          .post(
            `/api/v1/cbes/${this.$store.state.cbeId}/introduction_pages`, { cbe_introduction_page: this.pageDetails }
          )
          .then(response => {
            this.createdPage = response.data;
            if (this.createdPage.id > 0) {
              this.pageDetails["id"] = this.createdPage.id;
              this.$emit('add-introduction-page', this.pageDetails);
              this.pageDetails = {};
              this.title = this.initialTitle;
              this.content = this.initialContent;
              this.kind = this.initialKind;
            }
          })
          .catch(error => {
            console.log(error);
          });
      },
      updatePage: function() {
        this.pageDetails["title"]   = this.title;
        this.pageDetails["content"] = this.content;
        this.pageDetails["kind"]    = this.kind;

        axios
          .patch(
            `/api/v1/introduction_pages/${this.id}`, { cbe_introduction_page: this.pageDetails }
          )
          .then(response => {
            this.updatedPage = response.data;
            this.pageDetails["id"] = this.updatedPage.id;
            this.$emit('add-introduction-page', this.pageDetails);
            this.pageDetails = {};
            this.title = this.updatedPage.title;
            this.content = this.updatedPage.content;
            this.kind = this.updatedPage.kind;
          })
          .catch(error => {
            console.log(error);
          });
      }
    }
  };
</script>
