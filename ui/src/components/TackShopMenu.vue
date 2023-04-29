<template>
  <TackShopMenuItem
    v-for="(comp, index) in comps"
    :label="index"
    :maxItems="Object.keys(comp).length"
    :horseComps="comp"
    :key="index"
  />
  <TackShopCostDisplay :visible="showTackPrice" title="Tack Price" />
</template>

<script>
import { mapState } from "vuex";
import TackShopMenuItem from "./TackShopMenuItem.vue";
import TackShopCostDisplay from "./TackShopCostDisplay.vue";
export default {
  name: "TackShopMenu",
  props: {},
  components: {
    TackShopMenuItem,
    TackShopCostDisplay,
  },
  methods: {
    RenameHorse(id) {
      console.log(`Renaming Horse with the ID of ${id}`);
    },
    SellHorse(id) {
      console.log(`Selling Horse with the ID of ${id}`);
    },
  },
  computed: {
    ...mapState(["comps", "compCashPrice", "compGoldPrice", "showTackPrice"]),
  },
  beforeUnmount() {
    this.$store.dispatch("setCompCashPrice", 0);
    this.$store.dispatch("setCompGoldPrice", 0);
    this.$store.dispatch("setShowTackPrice", false);
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss"></style>
