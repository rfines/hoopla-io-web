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
    if @model.has 'location'
      @$el.find('.address').val(@model.get('location').address)
      if @$el.find('#map-canvas').length >0
        @showGeo(@model.get('location'))
      else
        setTimeout(()=>
        @showGeo(@model.get('location')),2000)
    else
      @$el.find('#map-canvas').hide()

  events:
    'change input' : 'mapLocation'
    'keydown input': 'stopEnterSubmit'
  stopEnterSubmit:(e)=>
    console.log e
    if e.keyCode is 13 and e.target.tagName is "INPUT" and not /^(button|reset|submit)$/i.test(e.target.type)
      e.preventDefault()
      @$el.find('.address').trigger('blur')
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
          map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);       
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
    p = new google.maps.LatLng(location.geo.coordinates[1], location.geo.coordinates[0])
    if @$el.find('#map-canvas') and not @$el.find('#map-canvas').is(':visible')
      @$el.find('#map-canvas').show()
    mapOptions =
      zoom: 16
      center: p
      mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
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