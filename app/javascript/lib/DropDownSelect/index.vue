<template>
  <div class="dropdown">
    <button
      :class="['btn btn-default dropdown-toggle', iconClass]"
      type="button"
      data-toggle="dropdown"
    >
      {{ buttonText }}
    </button>
    <ul class="dropdown-menu">
      <li
        v-for="option in dropdownOptions"
        :key="option[1]"
        @click="selectedValue(option[1])"
      >
        {{ option[0] }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    iconClass: {
      type: String,
      default: '',
    },
    buttonText: {
      type: String,
      default: '',
    },
    dropdownOptions: {
      type: Array,
      default() {
        return [];
      },
    },
  },
  methods: {
    selectedValue: function (value) {
      this.$emit('selected-value-updated', value);
    },
  },
};
</script>

<style scoped>
button {
  min-width: 30px;
}
.dropdown-toggle {
  padding: 0;
}

.dropdown-toggle:after {
  content: '';
  border: none;
}

.dropdown-menu {
  border: 0;
  padding: 1px;
  box-shadow: 1px 1px 5px #aaaaaa;
}

.dropdown-menu > li {
  cursor: pointer;
  padding: 9px;
  color: #212121;
  font-size: 12px;
}
.dropdown-menu > li:hover {
  background: #eaeaea;
  border: 1px solid blue;
}
</style>
