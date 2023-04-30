import axios from "axios";

const api = axios.create({
  baseURL: `https://${
    typeof GetParentResourceName !== "undefined"
      ? GetParentResourceName()
      : "bcc-stables"
  }/`,
});

export default api;
