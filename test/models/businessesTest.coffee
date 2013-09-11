Businesses = require 'models/businesses'

describe 'Business Collection', ->
  beforeEach ->
    @collection = new Businesses([{_id : 1}])

  afterEach ->
    @collection.dispose()

  it 'should have models', (done) ->
    @collection.models.length.should.equal 1
    done()