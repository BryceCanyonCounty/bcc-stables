<template>
  <div class="col s12 panel-shop item">
    <div class="col s6 item" @click="loadHorse()">
      <h6 class="grey-text-shop title">{{ horse.color }}</h6>
    </div>
    <div class="buy-buttons">
      <!--  -->
      <button class="btn-small" @click="buyHorse(true)">
        <img src="img/money.png" /><span>{{ horse.cashPrice }}</span>
      </button>
      <!--  -->
      <button class="btn-small right-btn" @click="buyHorse(false)">
        <img src="img/gold.png" /><span>{{ horse.goldPrice }}</span>
      </button>
      <!--  -->
    </div>
  </div>
</template>

<script>
import api from "@/api";
import { mapState } from "vuex";
export default {
  name: "TraderMenuColor",
  props: {
    horse: Object,
    model: String,
  },
  emits: ["iExpanded"],
  computed: {
    ...mapState(["activeHorse"]),
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
    loadHorse() {
      if (this.activeHorse) {
        this.$store.dispatch("setSelectedHorse", null);
      }

      api.post("loadHorse", {
        horseModel: this.model,
      });
    },
    buyHorse(isCash) {
      if (isCash) {
        api.post("BuyHorse", {
          ModelH: this.model,
          Cash: this.horse.cashPrice,
          IsCash: isCash,
        });
      } else {
        api.post("BuyHorse", {
          ModelH: this.model,
          Gold: this.horse.goldPrice,
          IsCash: isCash,
        });
      }
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.mb {
  margin-bottom: 0.75rem;
}

.mt {
  margin-top: 0.35rem;
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
.item {
  display: flex;
  justify-content: left;
  padding: 3px 3px !important;
}
.panel-shop.item {
  padding: 5px 0px !important;
  margin: 3px 10px !important;
  border-radius: 0px;
  width: calc(100% - 20px) !important;
  background-color: transparent;
  overflow: hidden;
  background-image: url("/public/img/input.png"), url("/public/img/input.png");
  background-size: 100% 100%;
  background-repeat: no-repeat;
  background-position: center;
}

.panel-shop.item:hover {
  background-image: url("/public/img/selected.png"),
    url("/public/img/selection_box.png");
}
.grey-text-shop.title {
  color: #9e9e9e;
  text-align: left;
  margin: auto 0;
}
.buy-buttons {
  display: flex;
}

.btn-small {
  display: flex !important;
  flex-direction: row !important;
  justify-content: left !important;
  align-items: center;
  text-decoration: none;
  color: #f0f0f0;
  user-select: none;
  text-align: left;
  width: 75px;
  letter-spacing: 0.5px;
  -webkit-transition: background-color 0.2s ease-out;
  transition: background-color 0.2s ease-out;
  border: 0px #fff solid;
}

.btn-small:hover {
  background: url("/public/img/buttonv.png");
  background-size: 90% 100%;
  background-repeat: no-repeat;
  background-position: right;
  border-radius: 0px;
}

.btn-small.right-btn {
  margin-right: 5px;
}

.title {
  font-size: 1em;
}
</style>
