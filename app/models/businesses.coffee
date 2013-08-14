Collection = require 'models/base/collection'
Business = require('models/business')

module.exports = class Businesses extends Collection
  Model : Business
  url: ->
    "/api/user/#{$.cookie('user')}/businesses"
  
