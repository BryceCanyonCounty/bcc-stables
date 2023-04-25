<template>
  <div class="col s12 mb">
    <!--  -->
    <div class="col s12 panel">
      <div class="col s12 panel-title" @click="[SelectHorse(), Expand()]">
        <h6 class="grey-text plus">{{ label }}</h6>
      </div>
    </div>
    <!--  -->
    <div v-if="isOpen">
      <div class="col s1"></div>
      <!--  -->
      <div class="col s10 panel-myhorse item">
        <button class="col s5 panel-col item-myhorse" @click="RenameHorse()">
          Rename
        </button>
        <button class="col s5 panel-col item-myhorse" @click="SellHorse()">
          Sell
        </button>
      </div>
      <!--  -->
      <div class="col s1"></div>
    </div>
  </div>
</template>

<script>
export default {
  name: "MyStableMenuItem",
  props: {
    label: String,
    index: Number,
    selected: Number,
  },
  emits: ["iExpanded"],
  computed: {
    isOpen() {
      return this.index == this.selected;
    },
  },
  methods: {
    Expand() {
      if (!this.isOpen) {
        this.$emit("iExpanded", this.index);
      }
    },
    SelectHorse() {
      if (!this.isOpen) {
        console.log(`Select Horse with the ID of ${this.index}`);
      }
    },
    RenameHorse() {
      console.log(`Renaming Horse with the ID of ${this.index}`);
    },
    SellHorse() {
      console.log(`Selling Horse with the ID of ${this.index}`);
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.mb {
  margin-bottom: 0.75rem;
}
</style>
