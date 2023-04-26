<template>
  <li style="margin-bottom: 0.5rem">
    <div class="collapsible-header col s12 panel">
      <div class="col s12 panel-title" @click="Expand()">
        <h6 class="grey-text plus">{{ horse.breed }}</h6>
      </div>
    </div>
    <div v-if="isOpen">
      <div
        class="collapsible-body item-bg"
        v-for="(color, model) in horse.colors"
        :key="model"
      >
        <TraderMenuColor :horse="color" :model="model" />
      </div>
    </div>
  </li>
</template>

<script>
// import api from "@/api";
import { mapState } from "vuex";
import TraderMenuColor from "./TraderMenuColor.vue";
export default {
  name: "TraderMenuItem",
  props: {
    horse: Object,
    index: Number,
    selected: Number,
  },
  emits: ["iExpanded"],
  computed: {
    ...mapState(["shopName", "myHorses", "horses", "comps", "activeHorse"]),
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
  },
  components: {
    TraderMenuColor,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.mb {
  margin-bottom: 0.75rem;
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
.panel {
  padding: 0px !important;
  margin: 3px 10px !important;
  border-radius: 0px;
  width: calc(100% - 20px) !important;
  background-color: transparent;
  overflow: hidden;
  background: url("/public/img/input.png");
  background-size: 100% 100%;
}
.panel-title {
  background-size: 100% 100%;
  padding: 10px 10px !important;
  font-size: 1.5em;
  font-weight: 400;
  text-align: center;
}

.panel-title .grey-text {
  margin: 0;
  margin-top: 5px;
  margin-bottom: 5px;
}

.grey-text.plus:hover {
  color: #f0f0f0;
}

.panel-title .grey-text {
  color: #9e9e9e;
  margin: 0;
  margin-top: 5px;
  margin-bottom: 5px;
}
</style>
