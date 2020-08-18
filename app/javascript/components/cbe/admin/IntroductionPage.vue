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
            >
          </div>
          <p
            v-if="!$v.title.required && $v.title.$error"
            class="error-message"
          >
            field is required
          </p>
        </div>
      </div>

      <div class="col-sm-4">
        <div class="form-group">
          <label for="sortingOrder">Sorting Order</label>
          <div class="input-group input-group-lg">
            <input
              id="sortingOrder"
              v-model="sortingOrder"
              placeholder="Sorting Order"
              class="form-control"
              type="number"
            >
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
            :field-model.sync="content"
            :aditional-toolbar-options="['fullscreen code image']"
            :editor-id="'introPagesEditor' + id"
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
        <button
          v-if="id"
          class="btn btn-primary"
          @click="updatePage"
        >
          Update Page
        </button>
        <button
          v-if="id"
          class="btn btn-danger"
          @click="deletePage"
        >
          Delete Page
        </button>
        <button
          v-else
          class="btn btn-primary"
          @click="savePage"
        >
          Save Page
        </button>

        <p
          v-if="updateStatus === 'ERROR'"
          class="typo__p"
        >
          Please fill the form correctly.
        </p>
        <p
          v-if="updateStatus === 'PENDING'"
          class="typo__p"
        >
          Updating...
        </p>
        <p
          v-if="deleteStatus === 'PENDING'"
          class="typo__p"
        >
          Deleting...
        </p>
        <p
          v-if="submitStatus === 'ERROR'"
          class="typo__p"
        >
          Please fill the form correctly.
        </p>
        <p
          v-if="submitStatus === 'PENDING'"
          class="typo__p"
        >
          Sending...
        </p>
      </div>
    </div>
  </b-tab>
</template>

<script>
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required, numeric } from 'vuelidate/lib/validators';
import TinyEditor from '../../TinyEditor.vue';

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
    initialContent: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      pageDetails: {},
      title: this.initialTitle,
      sortingOrder: this.initialSortingOrder,
      content: this.initialContent,
      submitStatus: null,
      updateStatus: null,
      deleteStatus: null,
    };
  },
  validations: {
    title: {
      required,
    },
    sortingOrder: {
      required,
      numeric,
    },
    content: {
      required,
    },
  },
  computed: {
    tabTitle() {
      return this.initialTitle.length > 0
        ? this.initialTitle
        : 'New Introduction Page';
    },
  },
  methods: {
    savePage() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR';
      } else {
        this.submitStatus = 'PENDING';
        this.pageDetails.title = this.title;
        this.pageDetails.content = this.content;
        this.pageDetails.cbe_id = this.$store.state.cbeId;
        this.pageDetails.sorting_order = this.sortingOrder;

        axios
          .post(`/api/v1/cbes/${this.$store.state.cbeId}/introduction_pages`, {
            cbe_introduction_page: this.pageDetails,
          })
          .then(response => {
            this.createdPage = response.data;
            if (this.createdPage.id > 0) {
              this.submitStatus = 'OK';
              this.pageDetails.id = this.createdPage.id;
              this.$emit('add-introduction-page', this.pageDetails);
              this.pageDetails = {};
              this.title = this.initialTitle;
              this.content = null;
              this.sortingOrder += 1;
              this.$v.$reset();
            }
          })
          .catch(error => {
            this.submitStatus = 'ERROR';
            console.log(error);
          });
      }
    },
    updatePage() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        this.updateStatus = 'ERROR';
      } else {
        this.updateStatus = 'PENDING';
        this.pageDetails.title = this.title;
        this.pageDetails.content = this.content;
        this.pageDetails.sorting_order = this.sortingOrder;

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
            this.pageDetails.id = this.updatedPage.id;
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
    deletePage() {
      if(confirm("Do you really want to delete?")){
        this.$v.$touch();
        if (this.$v.$invalid) {
          this.updateStatus = 'ERROR';
        } else {
          this.deleteStatus = 'PENDING';
          const pageId = this.id;

          axios
            .delete(
              `/api/v1/cbes/${this.$store.state.cbeId}/introduction_pages/${pageId}`
            )
            .then(response => {
              this.$emit('rm-introduction-page', pageId);
              this.updateStatus = 'OK';
              this.$v.$reset();
            })
            .catch(error => {
              this.updateStatus = 'ERROR';
              console.log(error);
            });
        }
      }
    },
  },
};
</script>
