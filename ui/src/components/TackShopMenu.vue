<template>
  <TackShopMenuItem
    v-for="(comp, index) in comps"
    :label="index"
    :maxItems="Object.keys(comp).length"
    :horseComps="comp"
    :key="index"
  />
</template>

<script>
import { mapState } from "vuex";
import TackShopMenuItem from "./TackShopMenuItem.vue";
export default {
  name: "TackShopMenu",
  props: {},
  components: {
    TackShopMenuItem,
  },
  methods: {
    RenameHorse(id) {
      console.log(`Renaming Horse with the ID of ${id}`);
    },
    SellHorse(id) {
      console.log(`Selling Horse with the ID of ${id}`);
    },
  },
  computed: mapState(["comps"]),
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
</style>
