import { createStore } from "vuex";

export default createStore({
  state: {
    myHorses: null,
    horses: null,
    shopName: null,
    comps: null,
    activeHorse: null,
    compCashPrice: 0,
    compGoldPrice: 0,
  },
  getters: {},
  mutations: {
    SET_MY_HORSES(state, payload) {
      state.myHorses = payload;
    },
    SET_HORSES(state, payload) {
      state.horses = payload;
    },
    SET_SHOP_NAME(state, payload) {
      state.shopName = payload;
    },
    SET_COMPONENTS(state, payload) {
      state.comps = payload;
    },
    SET_SELECTED_HORSE(state, payload) {
      state.activeHorse = payload;
    },
    SET_COMP_CASH_PRICE(state, payload) {
      state.compCashPrice = payload;
    },
    SET_COMP_GOLD_PRICE(state, payload) {
      state.compGoldPrice = payload;
    },
  },
  actions: {
    setMyHorses(context, payload) {
      context.commit("SET_MY_HORSES", payload);
    },
    setHorses(context, payload) {
      context.commit("SET_HORSES", payload);
    },
    setShopName(context, payload) {
      context.commit("SET_SHOP_NAME", payload);
    },
    setComponents(context, payload) {
      context.commit("SET_COMPONENTS", payload);
    },
    setSelectedHorse(context, payload) {
      context.commit("SET_SELECTED_HORSE", payload);
    },
    setCompCashPrice(context, payload) {
      context.commit("SET_COMP_CASH_PRICE", payload);
    },
    setCompGoldPrice(context, payload) {
      context.commit("SET_COMP_GOLD_PRICE", payload);
    },
  },
  modules: {},
});
