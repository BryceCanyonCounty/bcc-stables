<template>
  <div v-if="myHorses">
    <div v-if="Object.keys(myHorses).length">
      <div>
        <MyStableMenuItem
          :label="horse.name"
          :index="horse.id"
          :model="horse.model"
          :horse="horse"
          :components="JSON.parse(horse.components)"
          :selected="activeDropdown"
          v-for="(horse, index) in myHorses"
          :key="index"
          @iExpanded="onChildExpansion($event)"
        />
      </div>
    </div>
    <div v-else>No Horses. Head to the Trader.</div>
  </div>
  <div v-else>Loading...</div>
</template>

<script>
import { mapState } from "vuex";
import MyStableMenuItem from "./MyStableMenuItem.vue";
export default {
  name: "MyStableMenu",
  data() {
    return {
      activeDropdown: -1,
    };
  },
  methods: {
    onChildExpansion(event) {
      this.activeDropdown = event;
    },
  },
  components: {
    MyStableMenuItem,
  },
  computed: mapState(["myHorses", "activeHorse"]),
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
</style>
