<template>
  <div id="content" v-if="visible || devmode">
    <router-view />
  </div>
</template>
<script>
import "@/assets/css/style.css";
export default {
  name: "DefaultLayout",
  data() {
    return {
      devmode: false,
      visible: false,
    };
  },
  mounted() {
    window.addEventListener("message", this.onMessage);
  },
  methods: {
    onMessage(event) {
      switch (event.data.action) {
        case "show":
          this.visible = true;
          this.$store.dispatch("setHorses", event.data.shopData);
          this.$store.dispatch("setShopName", event.data.location);
          this.$store.dispatch("setTranslation", event.data.transData);
          this.$store.dispatch(
            "setComponents",
            Object.fromEntries(Object.entries(event.data.compData).sort())
          );
          this.$store.dispatch("setCurrencyType", event.data.currencyType);
          break;
        case "updateMyHorses":
          this.$store.dispatch("setMyHorses", event.data.myHorsesData);
          break;
        case "hide":
          this.visible = false;
          this.$store.dispatch("setMyHorses", null);
          this.$store.dispatch("setHorses", null);
          this.$store.dispatch("setShopName", null);
          this.$store.dispatch("setTranslation", null);
          this.$store.dispatch("setComponents", null);
          this.$store.dispatch("setSelectedHorse", null);
          this.$store.dispatch("setCompCashPrice", 0);
          this.$store.dispatch("setCompGoldPrice", 0);
          this.$store.dispatch("setShowTackPrice", false);
          this.$store.dispatch("setAllowSave", false);
          this.$store.dispatch("setCurrencyType", null);
          break;
        default:
          break;
      }
    },
  },
};
</script>
<style lang="scss">
#content {
  overflow: hidden;
}
</style>
