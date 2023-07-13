<template>
  <div class="modal-wrapper" v-if="visible">
    <!-- <div class="modal-overlay" @click="close"></div> -->
    <div class="modal">
      <div class="modal-header">
        <span>{{ title }}</span>
      </div>
      <div class="modal-body">
        <div class="flex cta-wrapper">
          <button
            @click="buyWithCash"
            class="modal-btn flex flex-auto"
            v-if="useCash"
          >
            <img src="img/money.png" />{{ compCashPrice }}
          </button>
          <!--  -->
          <button
            @click="buyWithGold"
            class="modal-btn flex flex-auto"
            v-if="useGold"
          >
            <img src="img/gold.png" />{{ compGoldPrice }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
export default {
  name: "TackShopCostDisplay",
  props: {
    visible: {
      type: Boolean,
      required: true,
    },
    title: {
      type: String,
      default: "Modal Title",
    },
  },
  methods: {
    close() {
      this.$emit("update:visible", false);
    },
  },
  computed: {
    ...mapState(["compCashPrice", "compGoldPrice", "currencyType"]),
    isActive() {
      return this.label == this.selectedPage;
    },
    useCash() {
      return this.currencyType < 1 || this.currencyType > 1;
    },
    useGold() {
      return this.currencyType > 0;
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.flex {
  display: flex;
}
.flex-auto {
  flex: 1 1 auto;
}
.modal-wrapper {
  position: fixed;
  z-index: -1;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-overlay {
  position: absolute;
  z-index: -1;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
}

.modal {
  position: absolute;
  top: 5%;
  right: 2%;
  z-index: -1;
  width: 80%;
  max-width: 15vw;
  padding: 1rem;
  background: url("/public/img/bgPanel.png");
  background-size: 100% 100%;
  border-radius: 0.5rem;
}

.modal-header {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 1rem;
  font-family: "crock";
  font-size: 1.5em;
  background: url("/public/img/menu_header.png");
  background-position: center;
  background-size: 100% 100%;
  background-repeat: no-repeat;
  padding: 15px 20px;
}

.modal-header h2 {
  margin: 0;
}

.modal-close {
  border: none;
  background-color: transparent;
  font-size: 2rem;
}

.modal-body {
  margin: 1rem 0;
}
</style>
