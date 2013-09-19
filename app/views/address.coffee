template = require 'templates/address'
View = require 'views/base/view'

module.exports = class AddressView extends View
  autoRender: true
  className: 'address'
  template: template

  initialize: (options) ->
    if options.template
      @template = options.template
    super(options)


  attach: =>
    super
    console.log "mapping attach"
    if @model.has 'location'
      @$el.find('.address').val(@model.get('location').address)
      @showGeo(@model.get('location'))
    else
      @$el.find('#map-canvas').hide()

  events:
    'change input' : 'mapLocation'

  mapLocation: (e) =>
    console.log "mapping location"
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
          @$el.find('#map-canvas').show()
          google.maps.event.trigger(map, 'visible_changed')
          google.maps.event.trigger(map, 'resize')
          @location =
            geo : {type: "Point", coordinates : [results[0].geometry.location.lng(), results[0].geometry.location.lat()]}
            address : results[0].formatted_address
          n = @getNeighborhood(results)
          @location.neighborhood = n if n
        else
          console.log "Geocode was not successful for the following reason: " + status

  showGeo: (location) =>
    p = new google.maps.LatLng(location.geo.coordinates[1], location.geo.coordinates[0])
    console.log p
    mapOptions =
      zoom: 16
      center: p
    mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    map.setCenter(p)
    marker = new google.maps.Marker(
      map: map
      position: p
    )
    google.maps.event.trigger(map, 'resize')
    @location = location



  getNeighborhood: (results) ->
    ac = results[0].address_components
    match = _.find ac, (item) ->
      item.types.indexOf('neighborhood') > -1
    if match
      return match.long_name

  getLocation: ->
    @location