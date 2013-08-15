template = require 'templates/business/edit'
View = require 'views/base/view'
Business = require 'models/business'

module.exports = class BusinessEditView extends View
  autoRender: true
  className: 'users-list'
  template: template

  initialize: ->
    super
    @model = new Business()

  attach: ->
    super


  events:
    'submit form' : 'save'
    'change input,textarea,select' : 'mapLocation'

  mapLocation: (e) =>
    line1 = @$el.find('.address1').val()
    line2 = @$el.find('.address2').val()
    city = @$el.find('.city').val()
    state = @$el.find('.state').val()
    zip = @$el.find('.postalCode').val()
    if line1 and city and state and zip
      geocoder = new google.maps.Geocoder()
      geocoder.geocode {address: "#{line1} #{line2}, #{city}, #{state} #{zip}"}, (results, status) =>
        if status is google.maps.GeocoderStatus.OK
          mapOptions = 
            zoom: 16
            center: results[0].geometry.location
            mapTypeId: google.maps.MapTypeId.ROADMAP
          map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);        
          marker = new google.maps.Marker(
            map: map
            position: results[0].geometry.location
          )
          google.maps.event.trigger(map, 'resize')
          @model.set 'geo', {type: "Point", coordinates : [results[0].geometry.location.lng(), results[0].geometry.location.lat()]}
          console.log @model.get('geo')
        else
          console.log "Geocode was not successful for the following reason: " + status



  save: (e) ->
    e.preventDefault()
    console.log 'save'
    @model.set
      name : @$el.find('.name').val()
      description : @$el.find('.description').val()
      address: 
        line1: @$el.find('.address1').val()
        line2: @$el.find('.address2').val()
        city: @$el.find('.city').val()
        state_province: @$el.find('.state').val()
        postal_code: @$el.find('.postalCode').val()
      geo :
        "type" : "Point"
        "coordinates" : [-94.58267601970849,39.11036]        
    @model.save()