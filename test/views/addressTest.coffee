Address = require 'views/address'

class AddressTest
  render: ->
    super

describe 'Address Finder View', ->
  beforeEach ->
    @view = new Address()

  afterEach ->
    @view.dispose()

  it 'should pull the nieghborhood when available', ->
    geocodeResponse = [
      {
         "address_components" : [
            {
               "long_name" : "River Market",
               "short_name" : "River Market",
               "types" : [ "neighborhood", "political" ]
            }
         ]
      }
    ]
    @view.getNeighborhood(geocodeResponse).should.be.equal 'River Market'



