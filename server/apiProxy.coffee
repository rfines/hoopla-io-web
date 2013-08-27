CONFIG = require('config')
_ = require 'lodash'
url = require('url')
http = require('http')


handler = (req, res, method) ->
  switch method
    when "GET" then handleGet req, res
    when "POST" then handlePost req, res
    when "PUT" then handlePut req, res
    when "DELETE" then handleDelete req, res
    else 
      res.status = 400
      res.body = "Illegal Request Method"
      res.send

handleGet = (req, res)->
  o = getOptions('GET', req)
  creq = http.request(o, (cres) ->
    res.writeHead cres.statusCode, cres.headers
    cres.on "data", (chunk) ->
      res.write chunk
    cres.on "close", ->
      res.writeHead cres.statusCode, cres.headers
      res.end()
    cres.on 'end', (x) ->
      res.end()
  ).on("error", (e) ->
    res.writeHead 500
    res.end()
  )
  creq.end()

handlePost = (req, res)->
  o = getOptions('POST', req)
  creq = http.request(o, (cres) ->
    res.writeHead cres.statusCode, cres.headers
    cres.on "data", (chunk) ->
      res.write chunk
    cres.on "close", ->
      res.writeHead cres.statusCode, cres.headers
      res.end()
    cres.on 'end', (x) ->
      res.end()
  ).on("error", (e) ->
    res.writeHead 500
    res.end()
  )
  if req.headers['content-type'] is 'application/json'
    creq.write JSON.stringify(req.body)
    creq.end()
  else
    req.on "data", (chunk) ->
      creq.write chunk
    req.on "end", ->
      creq.end()

    
handlePut = (req, res)->
  o = getOptions('PUT', req)
  creq = http.request(o, (cres) ->
    res.writeHead cres.statusCode, cres.headers
    cres.on "data", (chunk) ->
      res.write chunk
    cres.on "close", ->
      res.writeHead cres.statusCode, cres.headers
      res.end()
    cres.on 'end', (x) ->
      res.end()
  ).on("error", (e) ->
    res.writeHead 500
    res.end()
  )
  if req.headers['content-type'] is 'application/json'
    creq.write JSON.stringify(req.body)
    creq.end()
  else
    req.on "data", (chunk) ->
      creq.write chunk
    req.on "end", ->
      creq.end()

handleDelete = (req, res) ->
  o = getOptions('DELETE', req)
  creq = http.request(o, (cres) ->
    res.writeHead cres.statusCode, cres.headers
    cres.on "data", (chunk) ->
      res.write chunk
    cres.on "close", ->
      res.writeHead cres.statusCode, cres.headers
      res.end()
    cres.on 'end', (x) ->
      res.end()
  ).on("error", (e) ->
    res.writeHead 500
    res.end()
  )
  creq.end()
    

rewriteUrl = (oldUrl) ->
  if oldUrl
    parts = require("url").parse(oldUrl)
    u = parts.path
    t = u.split('/')
    wo = _.without(t,'api', '')
    if not parts.search
      result = {url:wo.join('/')}
      return result
    else 
      result = {url:"#{wo.join('/')}", query:"#{parts.search}"}
      return result


getOptions = (method, req) ->
  newUrl = rewriteUrl(req.originalUrl)
  url = require('url').parse("#{CONFIG.apiUrl}/#{newUrl.url}")
  auth = new Buffer("#{CONFIG.apiKey}:#{CONFIG.apiSecret}").toString('base64')
  o = 
    hostname: url.hostname
    port: url.port
    path: url.path
    method: method
    headers: req.headers
  o.headers.authorization = "Basic #{auth}"
  delete o.headers.host if o.headers.host
  return o


module.exports = 
  handler: handler
