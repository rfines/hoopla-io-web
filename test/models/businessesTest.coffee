Businesses = require 'models/businesses'

class BusinessCollectionTest
  render: ->
    super

describe 'Business Collection', ->
  beforeEach ->
    @collection = new Businesses([{_id : 1}])

  afterEach ->
    @collection.dispose()

  it 'should have models', ->
    expect(@collection.models).to.have.length 1
