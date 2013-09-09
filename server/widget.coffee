CONFIG = require('config')
request = require('request')
eventTransformer = require('./eventTransformer')
_ = require('lodash')



module.exports.show = (req, res) ->
  auth = new Buffer("#{CONFIG.apiKey}:#{CONFIG.apiSecret}").toString('base64')
  url = require('url').parse("#{CONFIG.apiUrl}/widget/#{req.params.id}")
  widgetRequest = 
    url : "#{CONFIG.apiUrl}/widget/#{req.params.id}/results"
    hostname: url.hostname
    port: url.port
    path: url.path
    method: 'GET'
    headers: 
      authorization : "Basic #{auth}"    
  request widgetRequest, (err, resp, body) ->
    if body
      events = JSON.parse(body)
      events = _.map events, eventTransformer.transform
      data =
        development: CONFIG.development
        apiUrl : CONFIG.apiUrl
        cloudinary : CONFIG.cloudinary
        facebookClientId: CONFIG.facebook.key
        baseUrl : CONFIG.baseUrl
        events: events
      res.render "widget.hbs", data
    else
      res.end()

