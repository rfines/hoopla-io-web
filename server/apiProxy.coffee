CONFIG = require('config')
restify = require 'restify'
_request = require 'request'
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
  newUrl = rewriteUrl(req.originalUrl)
  url = url.parse("#{CONFIG.apiUrl}/#{newUrl.url}")
  auth = new Buffer("#{CONFIG.apiKey}:#{CONFIG.apiSecret}").toString('base64')
  o = 
    hostname: url.hostname
    port: url.port
    path: url.path
    method: "GET"
    headers: req.headers
  o.headers.authorization = "Basic #{auth}"
  delete o.headers.host if o.headers.host

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
  console.log req
  newUrl = rewriteUrl req.originalUrl
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'POST', newUrl.query, req.body)
  options.headers = options.headers || {}
  for x in _.keys(req.headers)
    options.headers[x] = req.headers[x] if not options.headers[x]
  delete options.headers.host if options.headers.host
  delete options.headers['accept-encoding'] if options.headers['accept-encoding']
  _request options, (err,clientResponse,body)->
    res.header("content-type", "application/json")
    res.statusCode = clientResponse.statusCode if clientResponse?.statusCode
    if err
      res.end err.toString()
    else
      res.end body.toString()

handlePut = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'PUT', newUrl.query, req.body)
  options.headers = options.headers || {}
  for x in _.keys(req.headers)
    options.headers[x] = req.headers[x] if not options.headers[x]
  delete options.headers.host if options.headers.host
  delete options.headers['accept-encoding'] if options.headers['accept-encoding']
  _request(options,(err,clientResponse,body)->
    res.header("content-type", "application/json")
    res.statusCode = clientResponse.statusCode if clientResponse?.statusCode
    if err
      res.end err.toString()
    else
      res.end body.toString()
  )

handleDelete = (req, res) ->
  newUrl = rewriteUrl req.originalUrl
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'DELETE', newUrl.query, req.body)
  options.headers = options.headers || {}
  for x in _.keys(req.headers)
    options.headers[x] = req.headers[x] if not options.headers[x]
  delete options.headers.host if options.headers.host
  delete options.headers['accept-encoding'] if options.headers['accept-encoding']
  _request(options,(err,clientResponse,body)->
    res.header("content-type", "application/json")
    res.statusCode = clientResponse.statusCode if clientResponse?.statusCode
    if err
      res.end err.toString()
    else
      res.end body.toString()
  )
    

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


buildOptions = (url, user,pass,method,query, body) ->
  options = {
    'auth':
      'user': user
      'pass': pass
      'sendImmediately': true
    'qs':query
    'method':method
    'uri':url
    'body': JSON.stringify(body)
    'headers': {"content-type":"application/json"}
  }
module.exports = 
  handler: handler
