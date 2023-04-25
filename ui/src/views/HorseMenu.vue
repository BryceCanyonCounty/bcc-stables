<template>
  <div id="creatormenu" style="display: block" class="row">
    <div id="creator-container" class="col s5">
      <div id="head">
        <div id="stable_name" class="header-text">{{ stableName }}</div>
      </div>

      <div id="button_menu" class="row main-nav-buttons">
        <MenuButton label="Stable" @click="page = 'Stable'" />
        <MenuButton label="Trader" @click="page = 'Trader'" />
        <MenuButton label="Tack Shop" @click="page = 'Tack Shop'" />
      </div>

      <div class="divider-menu-top"></div>

      <MyStableMenu :horses="myHorses" v-if="page == 'Stable'" />
      <TraderMenu :horses="horses" v-else-if="page == 'Trader'" />
      <TackShopMenu v-else />

      <div class="divider-menu-top"></div>

      <div id="bottom_buttons" class="row main-bottom-buttons">
        <button id="save" class="button-select" onclick="menuAction('save')">
          Save
        </button>
        <button id="rotate_left" class="button-select" onclick="rotate('left')">
          <i class="fas fa-chevron-left"></i>
        </button>
        <div id="rotate_label" class="rotate-text">
          <h6 class="grey-text">Rotate</h6>
        </div>
        <button
          id="rotate_right"
          class="button-select"
          onclick="rotate('right')"
        >
          <i class="fas fa-chevron-right"></i>
        </button>
        <button
          id="cancel"
          class="button-select"
          onclick="menuAction('cancel')"
        >
          Cancel
        </button>
      </div>

      <div class="divider-menu-bottom"></div>
    </div>
  </div>
</template>

<script>
// @ is an alias to /src
import MenuButton from "@/components/MenuButton.vue";
import MyStableMenu from "@/components/MyStableMenu.vue";
import TraderMenu from "@/components/TraderMenu.vue";
import TackShopMenu from "@/components/TackShopMenu.vue";

export default {
  name: "HorseMenu",
  data() {
    return {
      page: "Stable",

      //  Temp DATA
      stableName: "Saint Denis Stable",
      myHorses: [
        { id: 1, name: "Midnight" },
        { id: 2, name: "Strawberry" },
        { id: 3, name: "Spirit" },
      ],
      horses: [
        {
          breed: "American Paint",
          colors: {
            ["a_c_horse_americanpaint_greyovero"]: {
              color: "Grey Overo",
              cashPrice: 425,
              goldPrice: 20,
              sellPrice: 255,
            },
            ["a_c_horse_americanpaint_splashedwhite"]: {
              color: "Splashed White",
              cashPrice: 140,
              goldPrice: 6,
              sellPrice: 84,
            },
            ["a_c_horse_americanpaint_tobiano"]: {
              color: "Tobiano",
              cashPrice: 140,
              goldPrice: 6,
              sellPrice: 84,
            },
            ["a_c_horse_americanpaint_overo"]: {
              color: "Overo",
              cashPrice: 130,
              goldPrice: 6,
              sellPrice: 78,
            },
          },
        },
        {
          breed: "American Standardbred",
          colors: {
            ["a_c_horse_americanstandardbred_silvertailbuckskin"]: {
              color: "Silver Tail Buckskin",
              cashPrice: 400,
              goldPrice: 19,
              sellPrice: 240,
            },
            ["a_c_horse_americanstandardbred_palominodapple"]: {
              color: "Palomino Dapple",
              cashPrice: 150,
              goldPrice: 7,
              sellPrice: 90,
            },
            ["a_c_horse_americanstandardbred_black"]: {
              color: "Black",
              cashPrice: 130,
              goldPrice: 6,
              sellPrice: 78,
            },
            ["a_c_horse_americanstandardbred_buckskin"]: {
              color: "Buckskin",
              cashPrice: 130,
              goldPrice: 6,
              sellPrice: 78,
            },
            ["a_c_horse_americanstandardbred_lightbuckskin"]: {
              color: "Light Buckskin",
              cashPrice: 130,
              goldPrice: 6,
              sellPrice: 78,
            },
          },
        },
        {
          breed: "Andalusian",
          colors: {
            ["a_c_horse_andalusian_perlino"]: {
              color: "Perlino",
              cashPrice: 450,
              goldPrice: 21,
              sellPrice: 270,
            },
            ["a_c_horse_andalusian_rosegray"]: {
              color: "Rose Gray",
              cashPrice: 440,
              goldPrice: 21,
              sellPrice: 264,
            },
            ["a_c_horse_andalusian_darkbay"]: {
              color: "Dark Bay",
              cashPrice: 140,
              goldPrice: 6,
              sellPrice: 84,
            },
          },
        },
      ],
    };
  },
  components: {
    MenuButton,
    MyStableMenu,
    TraderMenu,
    TackShopMenu,
  },
  methods: {},
};
</script>

<style scoped></style>
