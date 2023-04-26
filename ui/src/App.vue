<template>
  <div id="content" v-if="visible || devmode">
    <router-view />
  </div>
</template>
<script>
import api from "./api";

export default {
  name: "DefaultLayout",
  data() {
    return {
      devmode: false,
      visible: false,
    };
  },
  mounted() {
    window.addEventListener("message", this.onMessage);
  },
  methods: {
    onMessage(event) {
      switch (event.data.action) {
        case "show":
          this.visible = true;
          this.$store.dispatch("setHorses", event.data.shopData);
          this.$store.dispatch("setShopName", event.data.location);
          break;
        case "updateMyHorses":
          this.$store.dispatch("setMyHorses", event.data.myHorsesData);
          break;
        case "hide":
          this.visible = false;
          this.$store.dispatch("setHorses", null);
          this.$store.dispatch("setShopName", null);
          this.$store.dispatch("setMyHorses", null);
          break;
        default:
          break;
      }
    },
    closeApp() {
      this.visible = false;
      api
        .post("updatestate", {
          state: this.visible,
        })
        .catch((e) => {
          console.log(e.message);
        });
    },
  },
};
</script>
<style lang="scss">
// #app {
//   font-family: Avenir, Helvetica, Arial, sans-serif;
//   -webkit-font-smoothing: antialiased;
//   -moz-osx-font-smoothing: grayscale;
//   text-align: center;
//   color: #fff;
// }

// h3 {
//   margin: 40px 0 0;
// }

// ol {
//   text-align: left;
// }

// a {
//   color: #42b983;
// }
// a:hover {
//   color: #fff;
//   cursor: pointer;
// }

#content {
  overflow: hidden;
}

// #close {
//   position: absolute;
//   right: 0;
//   top: 0;
// }

// nav {
//   padding: 30px;

//   a {
//     font-weight: bold;
//     color: #fff;

//     &.router-link-exact-active {
//       color: #42b983;
//     }
//   }

//   a:hover {
//     color: #42b983;
//     cursor: pointer;
//   }
// }
</style>
