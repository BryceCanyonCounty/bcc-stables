import axios from "axios";

const api = axios.create({
  baseURL: `https://${
    typeof GetParentResourceName !== "undefined"
      ? GetParentResourceName()
      : "oss_stables"
  }/`,
});

export default api;
