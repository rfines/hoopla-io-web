Model = require 'models/base/model'
ImageUtils = require 'utils/imageUtils'

module.exports = class Business extends Model
  url: ->
    if @isNew()
      return "/api/business"
    else
      return "/api/business/#{@id}"  

  validate: ->
    errors = []
    if not (@has('name') and @get('name').trim().length > 0)
      errors.push {p : 'name'}
    if not (@has('location') and @get('location').address)
      errors.push {p : 'address'}
    if not (@has('description') and @get('description').trim().length > 0)
      errors.push {p : 'description'}      
    if errors.length is 0
      return undefined
    else
      return errors

  addFacebookLink: (_url)->
    if _url.length >0
      if @get('socialMediaLinks')
        f = _.findWhere(@get('socialMediaLinks'), {target:'Facebook'})
        if not f
          if @get('socialMediaLinks')?.length <= 0
            @set 'socialMediaLinks', []
          @get('socialMediaLinks').push {target:'Facebook', url:_url}
        else
          links = _.filter(@get('socialMediaLinks'), (item)=>
            return item.target is not 'Facebook'
          )
          links.push {target:'Facebook', url:_url}
          @set 'socialMediaLinks', links
      else
          @set 'socialMediaLinks', []
          @get('socialMediaLinks').push {target:'Facebook', url:_url}

  addTwitterLink: (_url)->
    if _url.length >0
      if @get('socialMediaLinks')
        f = _.findWhere(@get('socialMediaLinks'), {target:'Twitter'})
        if not f
          if @get('socialMediaLinks')?.length <= 0
            @set 'socialMediaLinks', []

          @get('socialMediaLinks').push {target:'Twitter', url:_url}
        else
          links = _.filter(@get('socialMediaLinks'), (item)=>
            return item.target is not 'Twitter'
          )
          links.push {target:'Twitter', url:_url}
          @set 'socialMediaLinks', links
      else
          @set 'socialMediaLinks', []
          @get('socialMediaLinks').push {target:'Twitter', url:_url}

  addFoursquareLink: (_url)->
    if _url.length >0
      if @get('socialMediaLinks')
        f = _.findWhere(@get('socialMediaLinks'), {target:'Foursquare'})
        if not f
          if @get('socialMediaLinks')?.length <= 0
            @set 'socialMediaLinks', []
          @get('socialMediaLinks').push {target:'Foursquare', url:_url}
        else
          links = _.filter(@get('socialMediaLinks'), (item)=>
            return item.target is not 'Foursquare'
          )
          links.push {target:'Foursquare', url:_url}
          @set 'socialMediaLinks', links
      else
          @set 'socialMediaLinks', []
          @get('socialMediaLinks').push {target:'Foursquare', url:_url}

  imageUrl: (options) ->
    media = @get('media')
    if media?.length > 0
      return $.cloudinary.url(ImageUtils.getId(media[0].url), {crop: 'fill', height: options.height, width: options.width})  
    else
      return undefined

  clone: ->
    json = @toJSON()
    delete json.id
    delete json._id
    delete json._v
    return new Business(json)      