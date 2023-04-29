<template>
  <div>
    <TraderMenuItem
      :horse="horse"
      :index="index"
      :selected="activeDropdown"
      v-for="(horse, index) in horses"
      :key="index"
      @iExpanded="onChildExpansion($event, index)"
    />
  </div>
</template>

<script>
import TraderMenuItem from "./TraderMenuItem.vue";
import { mapState } from "vuex";
export default {
  name: "TraderMenu",
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
    TraderMenuItem,
  },
  computed: mapState(["horses"]),
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss"></style>
