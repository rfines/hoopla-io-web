CONFIG = require('config')
express = require("express")
app = express()
port = process.env.PORT || 3000

app.get "/", (req, res) ->
  data =
    development: CONFIG.development
    apiUrl : CONFIG.apiUrl
  res.render "index.hbs", data

app.configure ->
  app.set('view engine', 'hbs');
  app.set('views', __dirname + '/server/views');
  app.use(express.static(__dirname+'/public'));


app.listen(port);

