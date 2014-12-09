R = require 'ramda'
line = /.*\n/g
end = /;$/
start = /^return /

replace = R.curry (line, replacement, str) -> str.replace line, replacement
emptyFunction = (->).toString()

chopSemicolon = replace end, ''
chopReturn = replace start, ''
getLastStatement = R.compose chopReturn, chopSemicolon, R.trim, R.last, R.match line

shouldEvaluate = (parts) ->
  R.contains '===', parts

evalWith = R.curry (thisObj, code) ->
  try
    return (-> eval(code)).call thisObj
  catch e
    return code

evaulateTestCode = R.compose R.join(' '), R.useWith R.map, evalWith

module.exports = (fn, thisObj) ->
  if fn? && fn.toString() != emptyFunction
    s = getLastStatement fn
    parts = s.split ' '
    if shouldEvaluate(parts) && thisObj?
      return evaulateTestCode thisObj, parts
    else
      return s
  else
    ''
