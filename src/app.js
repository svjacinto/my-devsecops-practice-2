const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Hello from DevSecOps practice app");
});

app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

app.listen(3000, () => {
  console.log("App running on port 3000");
});
