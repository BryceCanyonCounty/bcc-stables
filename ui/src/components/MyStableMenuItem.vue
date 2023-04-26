<template>
  <div class="col s12 mb">
    <!--  -->
    <div class="col s12 panel">
      <div class="col s12 panel-title" @click="[SelectHorse(), Expand()]">
        <h6 class="grey-text plus">{{ label }}</h6>
        <h6 class="grey-text plus" v-if="isActive">Active</h6>
      </div>
    </div>
    <!--  -->
    <div v-if="isOpen">
      <div class="col s1"></div>
      <!--  -->
      <div class="col s10 panel-myhorse item">
        <button class="col s5 item-myhorse" @click="RenameHorse()">
          Rename
        </button>
        <button class="col s5 item-myhorse" @click="SellHorse()">Sell</button>
      </div>
      <!--  -->
      <div class="col s1"></div>
    </div>
  </div>
</template>

<script>
import api from "@/api";
export default {
  name: "MyStableMenuItem",
  props: {
    label: String,
    index: Number,
    model: String,
    active: Number,
    components: Object,
    selected: Number,
  },
  emits: ["iExpanded"],
  computed: {
    isOpen() {
      return this.index == this.selected;
    },
    isActive() {
      return this.active == 1;
    },
  },
  mounted() {
    console.log(`Horse: ${this.label} Active: ${this.active}`);
  },
  methods: {
    Expand() {
      if (!this.isOpen) {
        this.$emit("iExpanded", this.index);
      }
    },
    SelectHorse() {
      if (!this.isOpen) {
        api
          .post("selectHorse", {
            horseId: this.index,
          })
          .catch((e) => {
            console.log(e.message);
          });

        api.post("loadMyHorse", {
          HorseId: this.index,
          HorseModel: this.model,
          HorseComp: JSON.stringify(this.components),
        });
      }
    },
    RenameHorse() {
      api
        .post("RenameHorse", {
          horseId: this.index,
        })
        .catch((e) => {
          console.log(e.message);
        });
    },
    SellHorse() {
      api
        .post("sellHorse", {
          horseId: this.index,
        })
        .catch((e) => {
          console.log(e.message);
        });
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.mb {
  margin-bottom: 0.75rem;
}
.col {
  float: left;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  padding: 0 0.75rem;
  min-height: 1px;
}
.col.s12 {
  width: 100%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.row .col.s10 {
  width: 83.3333333333%;
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
.row .col.s5 {
  width: 41.6666666667%;
  margin-left: auto;
  left: auto;
  right: auto;
}
.col.s1 {
  width: 8.3333333333%;
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
  color: #9e9e9e;
  margin: 0;
  margin-top: 5px;
  margin-bottom: 5px;
}

.panel-myhorse.item {
  /*width: calc(100% - 60px) !important;
    height: 3vh;
    background: url('img/input.png'), url('img/input.png');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 100% 100%;
    margin: auto;*/
  width: calc(100% - 60px) !important;
  background-image: url("/public/img/input.png"), url("/public/img/input.png");
  background-position: center center;
  background-repeat: no-repeat;
  background-size: 100% 100%;
  margin: auto;
}

.item {
  display: flex;
  justify-content: left;
  padding: 3px 3px !important;
}

.item-myhorse {
  /*height: 3vh;*/
  border: 0px #fff solid;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 5px 3px !important;
  width: 50%;
  margin: auto;
  color: #9e9e9e;
  text-align: center;
}

.item-myhorse:hover {
  background: url("/public/img/buttonv.png");
  background-size: 90% 100%;
  background-position: center;
  background-repeat: no-repeat;
  color: #f0f0f0 !important;
}

.grey-text.plus:hover {
  color: #f0f0f0;
}
</style>
