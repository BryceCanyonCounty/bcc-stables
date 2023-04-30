import { createRouter, createWebHashHistory } from "vue-router";
import HorseMenu from "../views/HorseMenu.vue";

const routes = [
  {
    path: "/",
    name: "home",
    component: HorseMenu,
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
