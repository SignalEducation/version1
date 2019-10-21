<template>
  <b-tab :title="tabTitle">
    <div class="row">
      <div class="col-sm-8">
        <div class="form-group">
          <label for="pageTitle">Title</label>
          <div class="input-group input-group-lg">
            <input
              v-model="title"
              placeholder="Title"
              class="form-control"
              id="pageTitle"
            />
          </div>
          <p v-if="!$v.title.required && $v.title.$error" class="error-message">
            field is required
          </p>
        </div>
      </div>

      <div class="col-sm-4">
        <div class="form-group">
          <label for="sortingOrder">Sorting Order</label>
          <div class="input-group input-group-lg">
            <input
              v-model="sortingOrder"
              placeholder="Sorting Order"
              class="form-control"
              id="sortingOrder"
              type="number"
            />
          </div>
          <p
            v-if="!$v.sortingOrder.required && $v.sortingOrder.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>

      <div class="col-sm-12">
        <div class="form-group">
          <label for="pageContent">Page Content</label>
          <TinyEditor
            :fieldModel.sync="content"
            :aditionalToolbarOptions="['fullscreen code']"
            :editorId="'introPagesEditor' + id"
          />

          <p
            v-if="!$v.content.required && $v.content.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>

      <div>
        <button v-if="id" v-on:click="updatePage" class="btn btn-primary">
          Update Page
        </button>
        <button v-else v-on:click="savePage" class="btn btn-primary">
          Save Page
        </button>

        <p class="typo__p" v-if="updateStatus === 'ERROR'">
          Please fill the form correctly.
        </p>
        <p class="typo__p" v-if="updateStatus === 'PENDING'">Updating...</p>
        <p class="typo__p" v-if="submitStatus === 'ERROR'">
          Please fill the form correctly.
        </p>
        <p class="typo__p" v-if="submitStatus === 'PENDING'">Sending...</p>
      </div>
    </div>
  </b-tab>
</template>

<script>
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';
import TinyEditor from '../../TinyEditor';

export default {
  components: {
    TinyEditor,
  },
  mixins: [validationMixin],
  props: {
    id: {
      type: Number,
      default: 0,
    },
    initialTitle: {
      type: String,
      default: '',
    },
    initialSortingOrder: {
      type: Number,
      default: 1,
    },
    initialContent: String,
  },
  data: function() {
    return {
      pageDetails: {},
      title: this.initialTitle,
      sortingOrder: this.initialSortingOrder,
      content: this.initialContent,
      submitStatus: null,
      updateStatus: null,
    };
  },
  validations: {
    title: {
      required,
    },
    sortingOrder: {
      required,
    },
    content: {
      required,
    },
  },
  computed: {
    tabTitle: function() {
      return this.initialTitle.length > 0
        ? this.initialTitle
        : 'New Introduction Page';
    },
  },
  methods: {
    savePage: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        this.pageDetails['title'] = this.title;
        this.pageDetails['content'] = this.content;
        this.pageDetails['cbe_id'] = this.$store.state.cbeId;
        this.pageDetails['sorting_order'] = this.sortingOrder;

        axios
          .post(`/api/v1/cbes/${this.$store.state.cbeId}/introduction_pages`, {
            cbe_introduction_page: this.pageDetails,
          })
          .then(response => {
            this.createdPage = response.data;
            if (this.createdPage.id > 0) {
              this.submitStatus = 'OK';
              this.pageDetails['id'] = this.createdPage.id;
              this.$emit('add-introduction-page', this.pageDetails);
              this.pageDetails = {};
              this.title = this.initialTitle;
              this.content = null;
              this.sortingOrder = this.initialSortingOrder;
              this.$v.$reset();
            }
          })
          .catch(error => {
            this.submitStatus = 'ERROR';
            console.log(error);
          });
      }
    },
    updatePage: function() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = 'ERROR';
      } else {
        this.updateStatus = 'PENDING';
        this.pageDetails['title'] = this.title;
        this.pageDetails['content'] = this.content;
        this.pageDetails['sorting_order'] = this.sortingOrder;

        axios
          .patch(
            `/api/v1/cbes/${this.$store.state.cbeId}/introduction_pages/${this.id}`,
            {
              cbe_introduction_page: this.pageDetails,
            }
          )
          .then(response => {
            this.updateStatus = 'OK';
            this.updatedPage = response.data;
            this.pageDetails['id'] = this.updatedPage.id;
            this.$emit('add-introduction-page', this.pageDetails);
            this.pageDetails = {};
            this.title = this.updatedPage.title;
            this.content = this.updatedPage.content;
            this.sortingOrder = this.updatedPage.sorting_order;
            this.$v.$reset();
          })
          .catch(error => {
            this.updateStatus = 'ERROR';
            console.log(error);
          });
      }
    },
  },
};
</script>
