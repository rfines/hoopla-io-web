CONFIG = require('config')
express = require("express")
app = express()
port = process.env.PORT || 3000

app.configure ->
  app.set('view engine', 'hbs')
  app.set('views', __dirname + '/server/views')
  app.use('/client', express.static(__dirname+'/public'))
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(express.cookieSession({secret:'secret_heh'}))
  
#api urls use proxy to set headers
app.get "/api/*", (req, res) ->
  require('./server/apiProxy').handler(req,res,"GET")
app.post "/api/*", (req,res) ->
  require('./server/apiProxy').handler(req,res,'POST')
app.put "/api/*", (req,res) ->
  require('./server/apiProxy').handler(req,res,'PUT')
app.delete "/api/*", (req,res) ->
  require('./server/apiProxy').handler(req,res,'DELETE')

app.get "/robots.txt", (req, res) ->
  res.set
    'Content-Type': 'text/plain'
  res.render CONFIG.robotsFile

app.get "/callbacks/facebook", (req, res) ->
  require('./server/callbacks').facebook(req, res)

app.get "/oauth/twitter", (req, res) ->
  require('./server/callbacks').oauthTwitter(req, res)
app.get "/callbacks/oauthTwitterCallback", (req, res) ->
  require('./server/callbacks').oauthTwitterCallback(req, res)

app.get "/*", (req, res) ->
  data =
    development: CONFIG.development
    apiUrl : CONFIG.apiUrl
    cloudinary : CONFIG.cloudinary
    facebookClientId: CONFIG.facebook.key
    baseUrl : CONFIG.baseUrl
  res.render "index.hbs", data

app.listen(port);
console.log "Started Hoopla.io - http://localhost:#{port}"
