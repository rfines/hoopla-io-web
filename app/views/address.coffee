template = require 'templates/address'
View = require 'views/base/view'

module.exports = class AddressView extends View
  className: 'address'
  template: template

  initialize: (options) ->
    if options.template
      @template = options.template
    super(options)

  attach: =>
    super()
    console.log "attaching address subview"
    if @model.has 'location'
      console.log "model has a location of course"
      @$el.find('.address').val(@model.get('location').address)
      @showGeo(@model.get('location'))
    else
      @$el.find('#map-canvas').hide()

  events:
    'change input' : 'mapLocation'

  mapLocation: (e) =>
    address = @$el.find('.address').val()
    @$el.find('#map-canvas').show()
    if address
      geocoder = new google.maps.Geocoder()
      geocoder.geocode {address: address}, (results, status) =>
        if status is google.maps.GeocoderStatus.OK
          mapOptions = 
            zoom: 16
            center: results[0].geometry.location
            mapTypeId: google.maps.MapTypeId.ROADMAP
          map = new google.maps.Map($('#map-canvas'), mapOptions);       
          marker = new google.maps.Marker(
            map: map
            position: results[0].geometry.location
          )
          google.maps.event.trigger(map, 'visible_changed')
          google.maps.event.trigger(map, 'resize')
          @location =
            geo : {type: "Point", coordinates : [results[0].geometry.location.lng(), results[0].geometry.location.lat()]}
            address : results[0].formatted_address
          n = @getNeighborhood(results)
          @location.neighborhood = n if n

  showGeo: (location) =>
    console.log "showing geo"
    p = new google.maps.LatLng(location.geo.coordinates[1], location.geo.coordinates[0])
    console.log @$el.find('#map-canvas')
    if @$el.find('#map-canvas') and not @$el.find('#map-canvas').is(':visible')
      @$el.find('#map-canvas').show()
    console.log "creating map options"
    mapOptions =
      zoom: 16
      center: p
      mapTypeId: google.maps.MapTypeId.ROADMAP
    console.log mapOptions
    map = new google.maps.Map($('#map-canvas'), mapOptions);
    console.log map
    map.setCenter(p)
    marker = new google.maps.Marker(
      map: map
      position: p
    )
    console.log "resizing map"
    google.maps.event.trigger(map, 'resize')
    console.log "resized map"
    @location = location  

  getNeighborhood: (results) ->
    ac = results[0].address_components
    match = _.find ac, (item) ->
      item.types.indexOf('neighborhood') > -1
    if match
      return match.long_name

  getLocation: ->
    @location