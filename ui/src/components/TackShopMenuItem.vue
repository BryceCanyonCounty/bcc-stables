<template>
  <div class="col s12 panel-cust">
    <div class="col s6 panel-col item-cust">
      <h6 class="grey-text-cust title">{{ label }}</h6>
    </div>
    <div class="col s6 panel-col">
      <button class="button-left col s4 btn" @click="decrease()">
        <i class="fas fa-chevron-left"></i>
      </button>
      <div class="col s4 panel-col item-count">
        <h6 class="grey-text-count title">{{ counter }}</h6>
      </div>
      <button class="button-right col s4 btn" @click="increase()">
        <i class="fas fa-chevron-right"></i>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: "TackShopMenuItem",
  props: {
    label: {
      type: String,
      required: true,
    },
    maxItems: {
      type: Number,
      required: true,
    },
    currentItem: {
      type: Number,
      default: 0,
    },
  },
  data() {
    return {
      curItem: this.currentItem,
    };
  },
  computed: {
    counter() {
      return `${this.curItem}/${this.maxItems}`;
    },
  },
  methods: {
    increase() {
      if (++this.curItem > this.maxItems) {
        this.curItem = 0;
      }
    },
    decrease() {
      if (--this.curItem < 0) {
        this.curItem = this.maxItems;
      }
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss"></style>
