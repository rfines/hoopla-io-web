CONFIG = require('config')
restify = require 'restify'
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
  client = getClient()
  client.get "/#{newUrl}", (err, request, response, obj) ->
    handleResponse err, req, res, response, obj

handlePost = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  client = getClient()
  client.post "/#{newUrl}", req.body, (err, request, response, obj) ->
    handleResponse err, req, res, response, obj

handlePut = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  client = getClient()
  client.put "#{newUrl}", req.body, (err,request,response,obj) ->
    handleResponse err, req, res, response, obj
  
handleDelete = (req, res) ->
  newUrl = rewriteUrl req.originalUrl
  client = getClient()
  client.delete "#{newUrl}", req.body, (err,request,response,obj) ->
    handleResponse err,req,res,response,obj

rewriteUrl = (oldUrl) ->
  if oldUrl
    parts = require("url").parse(oldUrl)
    u = parts.path
    t = u.split('/')
    wo = _.without(t,'api', '')
    if not parts.search
      result = wo.join('/')
      return result
    else 
      result = "#{wo.join('/')}#{parts.search}"
      return result

handleResponse = (err,request,oRes,response,obj)->
  if err
      console.log err
      oRes.headers = response.headers
      oRes.header('content-type', 'application/json')
      oRes.end err
    else
      oRes.headers = response.headers
      oRes.header('content-type','application/json')
      oRes.end JSON.stringify(obj)
      
module.exports = 
  handler: handler
