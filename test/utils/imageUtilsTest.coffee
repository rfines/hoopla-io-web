ImageUtils = require 'utils/imageUtils'

describe 'Image Utils', ->
  beforeEach ->

  afterEach ->

  it 'should get the id from a cloudinary url', ->
    id = ImageUtils.getId('http://res.cloudinary.com/hu9ncnicw/image/upload/v1377717172/xwjyep85rilpdwzbnxte.jpg')
    id.should.be.equal 'xwjyep85rilpdwzbnxte.jpg'