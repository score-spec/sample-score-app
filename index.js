const http = require("http");
const { Client } = require("pg");
const client = new Client({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "secret",
  database: process.env.DB_DATABASE || "score",
  port: process.env.DB_PORT || 5432,
});

const requestHandler = async (request, response) => {
  console.log(request.url);

  // Run hello world query
  const res = await client.query(
    `SELECT 'This is an application talking to a PostgreSQL database, deployed with Score!' as message`
  );

  const queryResult = res.rows[0].message;
  const message = process.env.MESSAGE || "Hello, World!";

  const html = `
  <html>
    <body>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
      <div class="container text-center mt-5 pt-5">
        <h1>${message}</h1>
        <p>${queryResult}</p>
      </div>
    </body>
  </html>
  `;

  response.end(html);
};

const App = async () => {
  // create the connection to database
  await client.connect();

  const server = http.createServer(requestHandler);

  const port = process.env.PORT || 8080;

  server.listen(port, (err) => {
    if (err) {
      return console.log("something bad happened", err);
    }

    console.log(`server is listening on ${port}`);
  });
};

App();

// Exit the process when signal is received (For docker)
process.on("SIGINT", () => {
  process.exit();
});
