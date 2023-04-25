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
      devmode: true,
      visible: false,
    };
  },
  mounted() {
    window.addEventListener("message", this.onMessage);
  },
  methods: {
    onMessage(event) {
      switch (event.data.type) {
        case "toggle":
          this.visible = event.data.visible;
          api
            .post("updatestate", {
              state: this.visible,
            })
            .catch((e) => {
              console.log(e.message);
            });
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
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #fff;
}

h3 {
  margin: 40px 0 0;
}

ol {
  text-align: left;
}

a {
  color: #42b983;
}
a:hover {
  color: #fff;
  cursor: pointer;
}

#content {
  background-color: rgb(32, 32, 32);
  border-radius: 6px;
  max-width: 500px;
  max-height: 800px;
  padding: 10px;

  position: absolute;
  top: 20%;
  left: 50%;

  transform: translate(-50%, -20%);
}

#close {
  position: absolute;
  right: 0;
  top: 0;
}

nav {
  padding: 30px;

  a {
    font-weight: bold;
    color: #fff;

    &.router-link-exact-active {
      color: #42b983;
    }
  }

  a:hover {
    color: #42b983;
    cursor: pointer;
  }
}
</style>
