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
      res.body = "Bad Request Method"
      res.send

handleGet = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  res.end "Test Get"
handlePost = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  client = getClient()
  client.post "/#{newUrl}", req.body, (err, req, response, obj) ->
    if err
      console.log err
    else
      console.log response.body
      console.log obj
      res.headers = response.headers
      res.header('content-type', 'application/json')
      res.end JSON.stringify(obj)
handlePut = (req, res)->
  newUrl = rewriteUrl req.originalUrl
  res.end "Test Put"
handleDelete = (req, res) ->
  newUrl = rewriteUrl req.originalUrl
  res.end "Test Delete"

rewriteUrl = (oldUrl) ->
  if oldUrl
    u = oldUrl
    t = u.split('/')
    wo = _.without(t,'api', '')
    result = wo.join('/')
    return "#{result}"

module.exports = 
  handler: handler
