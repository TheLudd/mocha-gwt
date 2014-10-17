R = require 'ramda'
line = /.*\n/g
end = /;$/
start = /^return /

replace = R.curry (line, replacement, str) -> str.replace line, replacement
emptyFunction = (->).toString()

chopSemicolon = replace end, ''
chopReturn = replace start, ''
getLastStatement = R.compose chopReturn, chopSemicolon, R.trim, R.last, R.match line

module.exports = (fn) ->
  if fn? && fn.toString() != emptyFunction
    getLastStatement fn
  else
    ''
