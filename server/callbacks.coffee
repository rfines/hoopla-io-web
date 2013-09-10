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
        me = "https://graph.facebook.com/me?access_token=#{accessToken}&fields=cover,id,name,link,username"
        request me, (errors, resp, bod)=>
          if errors
            handleError(res,facebookConnectError)
          else
            b=JSON.parse(bod)
            promoTarget = 
              accountType: 'FACEBOOK'
              accessToken: accessToken
              expiration: moment().add('seconds',slQstring.expires).toDate().toISOString()
              profileName: b.name
              profileId: b.id
              profileImageUrl: "https://graph.facebook.com/#{b.id}/picture?type=normal"
              profileCoverPhoto:b.cover
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
  twitterConnectError = 'We were unable to connect your business to Twitter.  Are you sure you approved the request?'
  oAuth = new oauth.OAuth(CONFIG.twitter.request_token_url, CONFIG.twitter.access_token_url, CONFIG.twitter.consumer_key, CONFIG.twitter.consumer_secret, "1.0A", "#{CONFIG.twitter.callback_url}?businessId=#{req.query.businessId}", "HMAC-SHA1")
  oAuth.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) =>
    if error
      handleError(res, twitterConnectError)
    else
      req.session.oauth = 
        token: oauth_token
        token_secret:oauth_token_secret
      res.redirect "https://twitter.com/oauth/authenticate?oauth_token=#{oauth_token}"

module.exports.oauthTwitterCallback = (req,res)->
  twitterConnectError = 'We were unable to connect your business to Twitter.  Are you sure you approved the request?'
  if req.query.businessId
    oAuth = new oauth.OAuth(CONFIG.twitter.request_token_url, CONFIG.twitter.access_token_url, CONFIG.twitter.consumer_key, CONFIG.twitter.consumer_secret, "1.0A", "#{CONFIG.twitter.callback_url}?businessId=#{req.query.businessId}", "HMAC-SHA1")
    if req.session.oauth
      req.session.oauth.verifier = req.query.oauth_verifier
      oauth_data = req.session.oauth
      oAuth.getOAuthAccessToken oauth_data.token, oauth_data.token_secret, oauth_data.verifier, (error, oauth_access_token, oauth_access_token_secret, results) =>
        if error
          handleError(res, twitterConnectError)
        else
          oAuth.get "https://api.twitter.com/1.1/account/settings.json", oauth_access_token, oauth_access_token_secret, (e, data, result) =>
            if e
              console.error e
            else
              console.log "Got the account settings"
              d = JSON.parse(data)
              console.log 
              oAuth.get "https://api.twitter.com/1.1/users/show.json?screen_name=#{d.screen_name}", oauth_access_token, oauth_access_token_secret, (e, user, result) =>
                if e
                  console.log e
                else
                  console.log "Got the user"
                  console.log user
                  promo = 
                    accessToken: oauth_access_token
                    accountType: 'TWITTER'
                    accessTokenSecret: oauth_access_token_secret
                    profileName: d.screen_name
                    profileId: JSON.parse(user).id
                    profileImageUrl: JSON.parse(user).profile_image_url
                  options=
                    uri:"#{CONFIG.baseUrl}api/business/#{req.query.businessId}/promotionTarget"
                    method:'POST'
                    json: promo
                  request options, (err, response, body)=>
                    if err
                      handleError(res, twitterConnectError)
                    else
                      res.redirect("#{CONFIG.baseUrl}myBusinesses")
             
    else
      handleError(res, twitterConnectError)
  else
    handleError(res, twitterConnectError)
