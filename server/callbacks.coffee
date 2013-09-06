request = require('request')
moment = require('moment')
CONFIG = require('config')
oauth = require('oauth')

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
        

module.exports.oauthTwitter = (req,res)->
  oAuth = new oauth.OAuth(CONFIG.twitter.request_token_url, CONFIG.twitter.access_token_url, CONFIG.twitter.consumer_key, CONFIG.twitter.consumer_secret, "1.0A", "#{CONFIG.twitter.callback_url}?businessId=#{req.query.businessId}", "HMAC-SHA1")
  oAuth.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) =>
    if error
      console.log error
      res.send "Authentication Failed"
    else
      req.session.oauth = 
        token: oauth_token
        token_secret:oauth_token_secret
      console.log(req.session.oauth)
      res.redirect "https://twitter.com/oauth/authenticate?oauth_token=#{oauth_token}"

module.exports.oauthTwitterCallback = (req,res)->
  twitterConnectError = 'We were unable to connect your business to twitter.  Are you sure you approved the request?'
  oAuth = new oauth.OAuth(CONFIG.twitter.request_token_url, CONFIG.twitter.access_token_url, CONFIG.twitter.consumer_key, CONFIG.twitter.consumer_secret, "1.0A", "#{CONFIG.twitter.callback_url}?businessId=#{req.query.businessId}", "HMAC-SHA1")
  if req.session.oauth
    req.session.oauth.verifier = req.query.oauth_verifier
    oauth_data = req.session.oauth
    oAuth.getOAuthAccessToken oauth_data.token, oauth_data.token_secret, oauth_data.verifier, (error, oauth_access_token, oauth_access_token_secret, results) =>
      if error
        handleError(res, twitterConnectError)
      else
        promo = 
          accessToken: oauth_access_token
          accountType: 'TWITTER'
          accessTokenSecret: oauth_access_token_secret
        options=
          uri:"#{CONFIG.baseUrl}api/business/#{req.query.businessId}/promotionTarget"
          method:'POST'
          json: promo
        request options, (err, response, body)=>
          res.redirect("#{CONFIG.baseUrl}myBusinesses")
           
  else
    res.redirect "/login" 
