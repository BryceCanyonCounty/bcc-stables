<template>
  <div class="container">
    <div class="main">
      <div class="header">
        <div class="header-text">
          {{ shopName }}
        </div>
      </div>

      <div class="btn-menu main-nav-buttons">
        <MenuButton
          label="Stable"
          :selectedPage="page"
          @click="page = 'Stable'"
          class="enabled"
        />
        <MenuButton
          label="Trader"
          :selectedPage="page"
          @click="page = 'Trader'"
          class="enabled"
        />
        <MenuButton
          label="Tack Shop"
          :selectedPage="page"
          @click="page = 'Tack Shop'"
          :class="{
            'disabled-btn': isClosed,
            enabled: !isClosed,
          }"
          :disabled="isClosed"
        />
      </div>

      <div class="divider-menu-top"></div>

      <div class="scroll-container" v-if="page == 'Stable'">
        <MyStableMenu />
      </div>

      <div class="scroll-container" v-else-if="page == 'Trader'">
        <TraderMenu />
      </div>

      <div class="scroll-container" v-else>
        <TackShopMenu />
      </div>

      <div class="divider-menu-top" style="margin-top: 1rem"></div>

      <div class="btn-bottom-main btn-bottom">
        <button
          id="save"
          @click="save()"
          :disabled="!hasCompsChanged"
          :class="{
            disabled: !hasCompsChanged,
            'btn-select': hasCompsChanged,
          }"
        >
          Save
        </button>
        <button
          id="rotate_left"
          class="btn-select btn-rotate"
          @click="rotate('left')"
        >
          <i class="fas fa-chevron-left center"></i>
        </button>
        <div class="rotate-text">
          <span class="grey-text center">Rotate</span>
        </div>
        <button
          id="rotate_right"
          class="btn-select btn-rotate"
          @click="rotate('right')"
        >
          <i class="fas fa-chevron-right center"></i>
        </button>
        <button id="cancel" class="btn-select" @click="close()">Cancel</button>
      </div>

      <div class="divider-menu-bottom"></div>
    </div>
    <ConfirmationModal
      :visible="showModal"
      title="Purchase"
      @close="hideModal()"
    >
      <p style="text-align: center">Purchase by selecting cash or gold.</p>
      <div class="divider-menu-top" style="margin-top: 1rem"></div>
      <div class="flex cta-wrapper">
        <button @click="purchase(0)" class="modal-btn flex flex-auto">
          <img src="img/money.png" />{{ compCashPrice }}
        </button>
        <!--  -->
        <button @click="purchase(1)" class="modal-btn flex flex-auto">
          <img src="img/gold.png" />{{ compGoldPrice }}
        </button>
        <!--  -->
        <button @click="hideModal" class="modal-btn flex flex-auto">
          Cancel
        </button>
      </div>
      <div class="divider-menu-bottom"></div>
    </ConfirmationModal>
  </div>
</template>

<script>
import { mapState } from "vuex";
import api from "@/api";
import MenuButton from "@/components/MenuButton.vue";
import MyStableMenu from "@/components/MyStableMenu.vue";
import TraderMenu from "@/components/TraderMenu.vue";
import TackShopMenu from "@/components/TackShopMenu.vue";
import ConfirmationModal from "@/components/ConfirmationModal.vue";

export default {
  name: "HorseMenu",
  data() {
    return {
      page: "Stable",
      showModal: false,
    };
  },
  components: {
    MenuButton,
    MyStableMenu,
    TraderMenu,
    TackShopMenu,
    ConfirmationModal,
  },
  methods: {
    hideModal() {
      this.showModal = false;
      this.$store.dispatch("setShowTackPrice", true);
    },
    save() {
      this.$store.dispatch("setShowTackPrice", false);
      this.showModal = true;
    },
    purchase(currency) {
      api
        .post("CloseStable", {
          MenuAction: "save",
          cashPrice: this.compCashPrice,
          goldPrice: this.compGoldPrice,
          currencyType: currency, // 0 = Cash 1 = Gold
        })
        .catch((e) => {
          console.log(e.message);
        });
    },
    close() {
      api
        .post("CloseStable", {
          MenuAction: "Close",
        })
        .catch((e) => {
          console.log(e.message);
        });
    },
    rotate(direction) {
      api.post("rotate", {
        RotateHorse: direction,
      });
    },
    buyWithCash() {
      console.log("Purchasing with Cash");
    },
    buyWithGold() {
      console.log("Purchasing with Gold");
    },
  },
  computed: {
    ...mapState(["shopName", "activeHorse", "compCashPrice", "compGoldPrice"]),
    isClosed() {
      return this.activeHorse === null;
    },
    hasCompsChanged() {
      return this.compCashPrice > 0;
    },
  },
};
</script>

<style scoped>
.container {
  padding-bottom: 40px;
  border-radius: 0px;
  overflow: hidden;
  position: absolute;
  height: 80vh;
  left: 2%;
  top: 5%;
  width: 420px;
  color: #e7e7e7 !important;
  background: url("/public/img/bgPanel.png");
  background-size: 100% 100%;
  display: block;
}

.header {
  margin: 0 -0.75rem;
  min-width: 420px;
  border-radius: 2px;
  overflow: hidden;
  transition: all 0.5s;
}
.flex {
  display: flex;
}
.flex-auto {
  flex: 1 1 auto;
}
.modal-btn {
  flex-direction: row;
  justify-content: center;
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
.modal-btn:hover {
  background: url("/public/img/buttonv.png");
  background-size: 90% 100%;
  background-repeat: no-repeat;
  background-position: right;
  border-radius: 0px;
}
.cta-wrapper {
  background: url("/public/img/input.png");
  background-position: center;
  background-size: 100% 100%;
  height: 4vh;
}
.header-text {
  position: relative;
  padding: 20px 20px;
  margin-top: 10px;
  margin-bottom: 10px;
  font-size: 2em;
  color: #f0f0f0;
  font-family: "crock";
  text-align: center;
  background: url("/public/img/menu_header.png");
  background-position: center;
  background-size: 85% 85%;
  background-repeat: no-repeat;
}

.btn-menu {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  border-radius: 0px;
  padding: 0px 20px;
  height: 5vh;
  background: url("/public/img/input.png");
  background-position: center;
  background-size: 95% 100%;
}
.main-nav-buttons {
  margin-top: 5px;
  margin-bottom: 15px;
}

.divider-menu-top,
.divider-menu-bottom {
  width: 90%;
  height: 4px;
  margin: auto auto;
  background-image: url("/public/img/divider_line.png");
  background-repeat: no-repeat;
  background-position: center;
  background-size: 100% 100%;
  opacity: 0.6;
}

.divider-menu-top {
  margin-bottom: 10px;
}

.divider-menu-bottom {
  margin-top: 10px;
}

.btn-bottom {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  border-radius: 0px;
  padding: 0px 20px;
  height: 4vh;
  background: url("/public/img/input.png");
  background-position: center;
  background-size: 95% 100%;
}

.btn-bottom-main {
  margin-top: 5px;
  margin-bottom: 5px;
}

.disabled {
  flex-grow: 1;
  font-size: 15px;
  border-radius: 0px;
  height: 4vh;
  border: 0px #fff solid;
  font-family: "robotoslab";
  font-weight: 500;
  letter-spacing: 1.5px;
  color: #4b4a4a;
  background-color: transparent !important;
}

.btn-select {
  flex-grow: 1;
  font-size: 15px;
  border-radius: 0px;
  height: 4vh;
  border: 0px #fff solid;
  font-family: "robotoslab";
  font-weight: 500;
  letter-spacing: 1.5px;
  color: #9e9e9e;
  background-color: transparent !important;
}

.btn-select:hover {
  background: url("/public/img/buttonv.png");
  background-size: 100% 100%;
  color: #f0f0f0;
}

.rotate-text {
  font-family: "robotoslab";
  font-weight: 500;
  font-size: 15px;
  margin: auto;
  padding: 0px 5px;
}

.grey-text {
  color: #9e9e9e;
}

.center {
  margin: auto;
}

.scroll-container::-webkit-scrollbar {
  display: none;
}

.scroll-container::-webkit-scrollbar-track {
  -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.1);
}

.scroll-container::-webkit-scrollbar-thumb {
  outline: 1px solid #313131;
  border-radius: 5px;
}

.scroll-container {
  overflow-y: auto;
  overflow-x: hidden;
  height: 54vh;
  width: 100%;
}

.btn-rotate {
  color: #d89a2e;
}
</style>
