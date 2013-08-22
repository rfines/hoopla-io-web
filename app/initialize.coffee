Application = require 'application'
routes = require 'routes'

$ ->
  new Application {
    title: 'Hoopla.io',
    controllerSuffix: '-controller',
    routes
  }
  Chaplin.datastore = {}