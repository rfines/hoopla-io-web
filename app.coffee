CONFIG = require('config')
express = require("express")
app = express()
port = process.env.PORT || 3000
widget = require('./server/widget')
apiProxy = require('./server/apiProxy')

app.configure ->
  if CONFIG.secure
    app.use (req, res, next) ->
      return res.redirect("https://" + req.get("Host") + req.url)  unless req.headers['x-forwarded-proto'] is 'https' or req.secure
      next()
  app.set('view engine', 'hbs')
  app.set('views', __dirname + '/server/views')
  app.use('/client', express.static(__dirname+'/public'))
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(express.cookieSession({secret:'secret_heh'}))
  app.use (err, req, res, next) ->
    console.error err.stack
    res.send 500, "Something broke!"
  
  
#api urls use proxy to set headers
app.get "/api/*", (req, res) ->
  apiProxy.handler(req,res,"GET")
app.post "/api/*", (req,res) ->
  apiProxy.handler(req,res,'POST')
app.put "/api/*", (req,res) ->
  apiProxy.handler(req,res,'PUT')
app.delete "/api/*", (req,res) ->
  apiProxy.handler(req,res,'DELETE')

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

app.get "/integrate/widget/:id", (req, res) ->
  widget.show(req, res)

app.get "/*", (req, res) ->
  data =
    development: CONFIG.development
    apiUrl : CONFIG.apiUrl
    cloudinary : CONFIG.cloudinary
    facebookClientId: CONFIG.facebook.key
    baseUrl : CONFIG.baseUrl
    googleAnalytics : CONFIG.googleAnalytics
  res.render "index.hbs", data

app.listen(port);
console.log "Started Hoopla.io - http://localhost:#{port}"
