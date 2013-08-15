CONFIG = require('config')
restify = require 'restify'
_request = require 'request'
_ = require 'lodash'

getClient = ->
  client = restify.createJsonClient({
      url: CONFIG.apiUrl,
      version: '*',
      headers: {"content-type": "application/json"}
    });

  client.basicAuth(CONFIG.apiKey, CONFIG.apiSecret)

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
  newUrl = rewriteUrl req.originalUrl
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'GET', newUrl.query)
  options.headers = {}
  options.headers = req.headers
  _request(options, (err, clientResponse, body)->
    if err
      console.log err
      res.header("content-type", "application/json")
      res.statusCode = clientResponse.statusCode
      res.end err.toString()
    else if clientResponse.statusCode is 200
      res.header("content-type", "application/json")
      console.log  "Status code 200: #{ body.toString()}"
      res.statusCode = clientResponse.statusCode
      res.end body.toString()
    else
      res.statusCode = clientResponse.statusCode
      console.log 'error: '+ clientResponse.statusCode
      console.log body.toString()
      res.end body.toString()
  )

handlePost = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  console.log req.body
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'POST', newUrl.query, req.body)
  _request(options,(err,clientResponse,body)->
    if err
      console.log err
      res.header("content-type", "application/json")
      res.statusCode = clientResponse.statusCode
      res.end err.toString()
    else if clientResponse.statusCode is 200
      res.header("content-type", "application/json")
      console.log  "Status code 200: #{body.toString()}"
      res.statusCode = clientResponse.statusCode
      res.end body.toString()
    else
      res.statusCode = clientResponse.statusCode
      console.log 'error: '+ clientResponse.statusCode
      console.log body.toString()
      res.end body.toString()
  )

handlePut = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'PUT', newUrl.query)

  client = getClient()
  client.put "#{newUrl.url}", req.body, (err,request,response,obj) ->
  
handleDelete = (req, res) ->
  newUrl = rewriteUrl req.originalUrl
  options = buildOptions("#{CONFIG.apiUrl}/#{newUrl.url}",CONFIG.apiKey, CONFIG.apiSecret,'DELETE', newUrl.query)

  client = getClient()
  client.delete "#{newUrl}", req.body, (err,request,response,obj) ->
    

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
  console.log url
  return options = {
    'auth':
      'user': user
      'pass': pass
      'sendImmediately': true
    'qs':query
    'method':method
    'uri':url
    'body': JSON.stringify(body)
  }
module.exports = 
  handler: handler
