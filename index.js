const { App } = require("@tinyhttp/app");

const app = new App();

app
  .get("/", (_, res) =>
    res.status(200).json({
      version: "v1",
    }),
  )
  .listen(3000);
