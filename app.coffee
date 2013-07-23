express = require("express")
app = express()


app.get "/", (req, res) ->
  data =
    name: "Ford Prefect"
    home: "a small planet somewhere in the vicinity of Betelgeuse"
  res.render "index.hbs", data

app.configure ->
  app.set('view engine', 'hbs');
  app.set('views', __dirname + '/server/views');
  app.use(express.static(__dirname+'/public'));


app.listen(3000, "127.0.0.1");

