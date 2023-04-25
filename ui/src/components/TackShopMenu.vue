<template>
  <div class="scroll-container">
    <TackShopMenuItem label="Saddlecloths" :maxItems="65" />
    <TackShopMenuItem label="Saddles" :maxItems="136" />
    <TackShopMenuItem label="Stirrups" :maxItems="11" />
    <TackShopMenuItem label="Saddle Horns" :maxItems="14" />
    <TackShopMenuItem label="Saddlebags" :maxItems="20" />
    <TackShopMenuItem label="Bedrolls" :maxItems="30" />
    <TackShopMenuItem label="Manes" :maxItems="102" />
    <TackShopMenuItem label="Tails" :maxItems="85" />
    <TackShopMenuItem label="Masks" :maxItems="51" />
    <TackShopMenuItem label="Mustaches" :maxItems="16" />
  </div>
</template>

<script>
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
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
</style>
