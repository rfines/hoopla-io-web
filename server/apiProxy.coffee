CONFIG = require('config')
_ = require 'lodash'
url = require('url')
http = require('http')
https = require('https')
request = require 'request'


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
  creq = getHttpLib(o).request(o, (cres) ->
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
  creq = getHttpLib(o).request(o, (cres) ->
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
  if req.headers['content-type'].indexOf('application/json') != -1
    creq.write JSON.stringify(req.body)
    creq.end()
  else
    req.on "data", (chunk) ->
      creq.write chunk
    req.on "end", ->
      creq.end()

    
handlePut = (req, res)->
  o = getOptions('PUT', req)
  creq = getHttpLib(o).request(o, (cres) ->
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
  if req.headers['content-type'].indexOf('application/json') != -1
    creq.write JSON.stringify(req.body)
    creq.end()
  else
    req.on "data", (chunk) ->
      creq.write chunk
    req.on "end", ->
      creq.end()

handleDelete = (req, res) ->
  o = getOptions('DELETE', req)
  creq = getHttpLib(o).request(o, (cres) ->
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
    protocol: url.protocol
    hostname: url.hostname
    port: url.port
    path: url.path
    method: method
    headers: req.headers
  o.headers.authorization = "Basic #{auth}"
  delete o.headers.host if o.headers.host
  return o

getHttpLib = (o) ->
  if o.protocol is 'https:'
    return https
  else
    return http

register = (body, cb) ->
  o = {
    url : require('url').parse("#{CONFIG.apiUrl}/user")
    json : body
    auth : {user: CONFIG.apiKey, pass: CONFIG.apiSecret, sendImmediately: true}
  }
  request.post o, (err, response, body) ->
    if err
      cb err, null
    else
      console.log response.statusCode
      if response.statusCode is 500
        console.log 'fail'
        cb body.message, null
      else
        o.url = require('url').parse("#{CONFIG.apiUrl}/tokenRequest")
        request.post o, (err, response, body) ->
          cb null, body

module.exports = 
  handler: handler
  request : request
  register: register