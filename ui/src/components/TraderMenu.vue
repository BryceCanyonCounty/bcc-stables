<template>
  <div class="scroll-container">
    <ul class="collapsible" v-for="(horse, index) in horses" :key="index">
      <li>
        <div class="collapsible-header col s12 panel">
          <div class="col s12 panel-title">
            <h6 class="grey-text plus">{{ horse.breed }}</h6>
          </div>
        </div>
        <div
          class="collapsible-body item-bg"
          v-for="(color, model) in horse.colors"
          :key="model"
        >
          <div :id="model" class="col s12 panel-shop item">
            <div class="col s6 panel-col item">
              <h6 class="grey-text-shop title">{{ color.color }}</h6>
            </div>
            <div class="buy-buttons">
              <button
                class="btn-small"
                onclick="buyHorse('${_}', ${priceCash}, true)"
              >
                <img src="img/money.png" /><span class="horse-price">{{
                  color.cashPrice
                }}</span>
              </button>
              <button
                class="btn-small right-btn"
                onclick="buyHorse('${_}', ${priceGold}, false)"
              >
                <img src="img/gold.png" /><span class="horse-price">{{
                  color.goldPrice
                }}</span>
              </button>
            </div>
          </div>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: "TraderMenu",
  props: {
    horses: Array,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
</style>
