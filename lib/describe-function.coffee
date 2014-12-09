R = require 'ramda'
tapLog = R.tap console.log
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

undefinedToString = (val) ->
  if val == undefined
    return 'undefined'
  else if val == null
    return 'null'
  else
    return val

joinAll = R.curry (separator, array) ->
  R.compose(R.join(separator), R.map(undefinedToString))(array)

evalWith = R.curry (thisObj, code) ->
  try
    res = (-> eval(code)).call thisObj
    return res
  catch e
    code

evaulateTestCode = R.compose joinAll(' '), R.useWith R.map, evalWith

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
