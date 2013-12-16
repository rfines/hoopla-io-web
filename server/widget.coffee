CONFIG = require('config')
request = require('request')
eventTransformer = require('./eventTransformer')
_ = require('lodash')


getOptions = (url) =>
  auth = new Buffer("#{CONFIG.apiKey}:#{CONFIG.apiSecret}").toString('base64')
  widgetRequest = 
    url : require('url').format(url)
    hostname: url.hostname
    port: url.port
    path: url.path
    method: 'GET'
    headers: 
      authorization : "Basic #{auth}"    
  return widgetRequest

module.exports.show = (req, res) ->
  configUrl = require('url').parse("#{CONFIG.apiUrl}/widget/#{req.params.id}")
  resultsUrl = require('url').parse("#{CONFIG.apiUrl}/widget/#{req.params.id}/results")
  resultsRequest = getOptions(resultsUrl) 
  configRequest = getOptions(configUrl)
  request configRequest, (err, resp, widget) ->
    widget = JSON.parse(widget)
    request resultsRequest, (err, resp, body) ->
      if err
        console.log err
        res.send 500
        res.end()
      if body
        events = []
        try
          events = JSON.parse(body)
        catch e
          events = body
        events = _.map events, eventTransformer.transform
        widget.height=widget.height-80
        data =
          development: CONFIG.development
          apiUrl : CONFIG.apiUrl
          cloudinary : CONFIG.cloudinary
          facebookClientId: CONFIG.facebook.key
          baseUrl : CONFIG.baseUrl
          events: events
          widget: widget
        res.render "widget.hbs", data
      else
        res.end()

