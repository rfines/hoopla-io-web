Application = require 'application'
routes = require 'routes'
Datastore = require 'datastore'

$ ->
  Chaplin.datastore = new Datastore()
  new Application {
    title: 'Hoopla.io',
    controllerSuffix: '-controller',
    routes
  }


  # debug helper
  # usage: {{debug}} or {{debug someValue}}
  # from: @commondream (http://thinkvitamin.com/code/handlebars-js-part-3-tips-and-tricks/)
  Handlebars.registerHelper "debug", (optionalValue) ->
    console.log "Current Context"
    console.log "===================="
    console.log this
    if optionalValue
      console.log "Value"
      console.log "===================="
      console.log optionalValue


  #  format an ISO date using Moment.js
  #  http://momentjs.com/
  #  moment syntax example: moment(Date("2011-07-18T15:50:52")).format("MMMM YYYY")
  #  usage: {{dateFormat creation_date format="MMMM YYYY"}}
  Handlebars.registerHelper "dateFormat", (context, block) ->
    if window.moment
      f = block.hash.format or "MM/DD/YYYY"
      return moment(context).format(f)
    else
      return context

  