template = require 'templates/address'
View = require 'views/base/view'

module.exports = class AddressView extends View
  autoRender: true
  className: 'users-list'
  template: template

  initialize: ->
    super

  attach: ->
    super

  events:
    'change input' : 'mapLocation'

  mapLocation: (e) =>
    address = @$el.find('.address').val()
    if address
      geocoder = new google.maps.Geocoder()
      geocoder.geocode {address: address}, (results, status) =>
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
          @location =
            geo : {type: "Point", coordinates : [results[0].geometry.location.lng(), results[0].geometry.location.lat()]}
            address : results[0].formatted_address
            neighborhood : @getNeighborhood(results)
        else
          console.log "Geocode was not successful for the following reason: " + status

  getNeighborhood: (results) ->
    ac = results[0].address_components
    match = _.find ac, (item) ->
      item.types.indexOf('neighborhood') > -1
    match.long_name

  getLocation: ->
    @location