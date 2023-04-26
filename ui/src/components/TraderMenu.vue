<template>
  <ul class="collapsible">
    <TraderMenuItem
      :horse="horse"
      :index="index"
      :selected="activeDropdown"
      v-for="(horse, index) in horses"
      :key="index"
      @iExpanded="onChildExpansion($event, index)"
    />
  </ul>
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
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
.row .col {
  margin-left: -0.75rem;
  margin-right: -0.75rem;
}
.col.s1 {
  width: 8.3333333333%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s2 {
  width: 16.6666666667%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s3 {
  width: 25%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s4 {
  width: 33.3333333333%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s5 {
  width: 41.6666666667%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s6 {
  width: 50%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s7 {
  width: 58.3333333333%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.row .col.s8 {
  width: 66.6666666667%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s9 {
  width: 75%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s10 {
  width: 83.3333333333%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s11 {
  width: 91.6666666667%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s12 {
  width: 100%;
  margin-left: auto;
  left: auto;
  right: auto;
}
ul {
  margin: 0;
  padding: 0;
  list-style-type: none;
}
</style>
