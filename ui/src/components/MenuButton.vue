<template>
  <button>{{ label }}</button>
</template>

<script>
export default {
  name: "MenuButton",
  props: {
    label: String,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
button {
  flex-grow: 1;
  border-radius: 0px;
  height: 5vh;
  border: 0px #fff solid;
  font-family: "robotoslab";
  font-weight: 500;
  letter-spacing: 1.5px;
  color: #9e9e9e;
  background-color: transparent !important;
  align-items: center;
}

button:hover {
  background: url("/public/img/input.png");
  background-size: 100% 100%;
  color: #f0f0f0;
  cursor: pointer;
}

button:active {
  background: url("/public/img/input.png");
  background-size: 100% 100%;
  color: #f0f0f0;
}
</style>
