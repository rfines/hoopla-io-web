Collection = require 'models/base/collection'
Business = require('models/business')

module.exports = class Businesses extends Collection
  model : Business
  url: ->
    "/api/user/#{$.cookie('user')}/businesses"

  comparator : (business) ->
    business.get('name').toLowerCase()

  hasOne: ->
    @length is 1

  hasNone: ->
    @length is 0

  hasMedia: (mediaId) ->
    @some (item) ->
      if item.has('media')
        return _.some item.get('media'), (i) ->
          i._id is mediaId    
      else
        return false