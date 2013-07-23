Application = require 'application'
routes = require 'routes'

$ ->
  console.log 'initialize'
  new Application {
    title: 'Brunch example application',
    controllerSuffix: '-controller',
    routes
  }
