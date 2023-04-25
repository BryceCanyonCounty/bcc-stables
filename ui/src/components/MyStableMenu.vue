<template>
  <div class="scroll-container">
    <div class="" v-for="(horse, index) in horses" :key="index">
      <MyStableMenuItem
        :label="horse.name"
        :index="horse.id"
        :selected="activeDropdown"
        @iExpanded="onChildExpansion($event)"
      />
    </div>
  </div>
</template>

<script>
import MyStableMenuItem from "./MyStableMenuItem.vue";
export default {
  name: "MyStableMenu",
  props: {
    horses: Array,
  },
  data() {
    return {
      activeDropdown: -1,
    };
  },
  methods: {
    onChildExpansion(event) {
      console.log("Event Triggered");
      this.activeDropdown = event;
    },
  },
  components: {
    MyStableMenuItem,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
</style>
