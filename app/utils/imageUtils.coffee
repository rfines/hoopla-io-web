module.exports.getId = (url) ->
  t = url.split('/')
  final = t[t.length-1]
  return final
  