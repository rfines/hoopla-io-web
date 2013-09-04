request = require('request')
moment = require('moment')
CONFIG = require('config')

handleError = (res, errorMsg) ->
  errorMsg = errorMsg || 'We were unable to connect your business.  Are you sure you approved the request?'
  res.redirect("#{CONFIG.baseUrl}myBusinesses?error=#{encodeURIComponent(errorMsg)}")

module.exports.facebook = (req, res) ->
  facebookConnectError = 'We were unable to connect your business to facebook.  Are you sure you approved the request?'
  if req.query.code
    facebookBaseUrl = "https://graph.facebook.com/oauth/access_token?client_id=#{CONFIG.facebook.key}&client_secret=#{CONFIG.facebook.secret}&"
    accessTokenRedirect = "#{CONFIG.baseUrl}callbacks/facebook?businessId=#{req.query.businessId}"
    accessTokenUrl = "#{facebookBaseUrl}code=#{req.query.code}&redirect_uri=#{encodeURIComponent(accessTokenRedirect)}"
    request accessTokenUrl, (err, response, body)=>
      if err
        handleError(res, facebookConnectError)
      else
        slQstring = require('querystring').parse("#{body}")
        accessToken = slQstring.access_token
        promoTarget = 
          accountType: 'FACEBOOK'
          accessToken: accessToken
          expiration: moment().add('seconds',slQstring.expires).toDate().toISOString()
        options=
          uri:"#{CONFIG.baseUrl}api/business/#{req.query.businessId}/promotionTarget"
          method:'POST'
          json: promoTarget
        request options, (err, response, body)=>
          if err
            handleError(res, facebookConnectError)
          else
            res.redirect("#{CONFIG.baseUrl}myBusinesses")
  else
    handleError(res, facebookConnectError)
        
  #3 create promotion target
  #4 update business to ref new promotion target
