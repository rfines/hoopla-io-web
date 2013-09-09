CONFIG = require('config')
request = require('request')

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
      data =
        development: CONFIG.development
        apiUrl : CONFIG.apiUrl
        cloudinary : CONFIG.cloudinary
        facebookClientId: CONFIG.facebook.key
        baseUrl : CONFIG.baseUrl
        events: JSON.parse(body)
      res.render "widget.hbs", data
    else
      res.end()