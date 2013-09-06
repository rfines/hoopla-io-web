module.exports.getId = (url) ->
  if url
    t = url.split('/')
    final = t[t.length-1]
    return final
  else
    return ''
  