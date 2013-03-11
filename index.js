require("coffee-script");
var main = require("./lib/main");
var queries = require("./queries/simple.json");
var services = require("./services.json");

main.run(services, queries);

