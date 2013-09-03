Model = require 'models/base/model'

module.exports = class Business extends Model
  url: ->
    if @isNew()
      return "/api/business"
    else
      return "/api/business/#{@id}"  

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