<template>
  <div class="tackshop">
    <div class="col s12 panel-cust mb">
      <div class="col s6 item-cust">
        <h6 class="grey-text-cust title">{{ label }}</h6>
      </div>
      <div class="col s6 flex justify-end">
        <!--  -->
        <button class="button-left btn flex-" @click="decrease()">
          <i class="fas fa-chevron-left"></i>
        </button>
        <!--  -->
        <div class="item-count flex-none">
          <h6 class="grey-text-count title">{{ counter }}</h6>
        </div>
        <!--  -->
        <button class="button-right btn flex-none" @click="increase()">
          <i class="fas fa-chevron-right"></i>
        </button>
        <!--  -->
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import api from "@/api";
export default {
  name: "TackShopMenuItem",
  props: {
    label: {
      type: String,
      required: true,
    },
    maxItems: {
      type: Number,
      required: true,
    },
    horseComps: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      curItem: 0,
    };
  },
  mounted() {
    let currentComps = JSON.parse(this.activeHorse["components"]);

    for (const [key, comp] of Object.entries(this.horseComps)) {
      if (
        Object.keys(currentComps).length &&
        currentComps.includes(comp["hash"])
      ) {
        this.curItem = parseInt(key);
        break;
      }
    }
  },
  computed: {
    ...mapState(["comps", "activeHorse", "compCashPrice", "compGoldPrice"]),
    counter() {
      return `${this.curItem}/${this.maxItems}`;
    },
  },
  watch: {
    curItem(newVal, oldVal) {
      if (oldVal > 0) {
        this.$store.dispatch(
          "setCompCashPrice",
          this.compCashPrice - parseInt(this.horseComps[oldVal]["cashPrice"])
        );
        this.$store.dispatch(
          "setCompGoldPrice",
          this.compGoldPrice - parseInt(this.horseComps[oldVal]["goldPrice"])
        );
      }

      if (newVal > 0) {
        this.$store.dispatch(
          "setCompCashPrice",
          this.compCashPrice + parseInt(this.horseComps[newVal]["cashPrice"])
        );
        this.$store.dispatch(
          "setCompGoldPrice",
          this.compGoldPrice + parseInt(this.horseComps[newVal]["goldPrice"])
        );
      }
    },
  },
  methods: {
    increase() {
      if (++this.curItem > this.maxItems) {
        this.curItem = 0;
      }
      this.updateItem();
    },
    decrease() {
      if (--this.curItem < 0) {
        this.curItem = this.maxItems;
      }
      this.updateItem();
    },
    updateItem() {
      api
        .post(this.label.replace(/\s+/g, ""), {
          id: this.curItem,
          hash: this.horseComps[this.curItem]["hash"],
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
.tackshop {
  width: 96%;
  margin: auto;
  overflow: hidden;
}
.mb {
  margin-bottom: 0.25rem;
}
.flex {
  display: flex;
}

.flex-none {
  flex: none;
}
.justify-end {
  justify-content: flex-end;
}
.col {
  margin-left: -0.75rem;
  margin-right: -0.75rem;
}
.col.s6 {
  width: 50%;
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

.panel-cust {
  background: url("/public/img/input.png");
  background-size: 100% 100%;
  padding: 0px;
  margin: 3px 10px;
  border-radius: 0px;
  width: calc(100% - 20px);
  background-color: transparent;
  overflow: hidden;
  font-weight: 400;
  display: flex;
  justify-content: center;
}

.grey-text-cust.title {
  color: #9e9e9e;
  text-align: left;
  margin: auto 0 auto;
  padding-left: 30px;
  font-size: 1em;
}

.item-cust {
  display: flex;
  justify-content: left;
  padding: 3px 3px;
  width: 50%;
  margin-left: auto;
  left: auto;
  right: auto;
}

.item-count {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 33.3333333333%;
  height: 46px;
  background-color: transparent;
  background-image: url("/public/img/input.png");
  background-position: center center;
  background-repeat: no-repeat;
  background-size: 100% 100%;
  // margin: auto;
}

.grey-text-count.title {
  color: #f0f0f0;
  text-align: center;
  margin: auto;
  font-size: 1em;
}

.button-left {
  font-size: 20px;
  padding-left: 25px;
  padding-right: 25px;
}

.button-right {
  font-size: 20px;
  padding-left: 25px;
  padding-right: 25px;
  margin-right: 15px;
}

.btn {
  display: flex;
  flex-direction: row;
  // justify-content: center;
  // align-items: center;
  text-decoration: none;
  color: #d89a2e;
  user-select: none;
  // text-align: center;
  letter-spacing: 0.5px;
  -webkit-transition: background-color 0.2s ease-out;
  transition: background-color 0.2s ease-out;
  cursor: pointer;
  border: 0px #fff solid;
}

.btn:active {
  user-select: none;
  border: 0px #fff solid;
}

.btn:hover {
  background: url("/public/img/buttonv.png");
  background-size: 100% 100%;
  background-repeat: no-repeat;
  color: #f0f0f0;
}
</style>
