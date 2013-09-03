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
  
  #  format an ISO date using Moment.js
  #  http://momentjs.com/
  #  moment syntax example: moment(Date("2011-07-18T15:50:52")).format("MMMM YYYY")
  #  usage: {{dateFormat creation_date format="MMMM YYYY"}}
  Handlebars.registerHelper "dateFormat", (context, block) ->
    if window.moment
      f = block.hash.format or "MMM Mo, YYYY"
      return moment(Date(context)).format(f)
    else
      return context #  moment plugin not available. return data as is.

  