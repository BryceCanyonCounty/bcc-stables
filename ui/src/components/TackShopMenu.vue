<template>
  <TackShopMenuItem
    v-for="(comp, index) in comps"
    :label="index"
    :translated="translation[index]"
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
  methods: {},
  computed: {
    ...mapState([
      "translation",
      "comps",
      "compCashPrice",
      "compGoldPrice",
      "showTackPrice",
      "allowSave",
    ]),
  },
  beforeUnmount() {
    this.$store.dispatch("setCompCashPrice", 0);
    this.$store.dispatch("setCompGoldPrice", 0);
    this.$store.dispatch("setShowTackPrice", false);
    this.$emit("toggleSave", false);
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss"></style>
