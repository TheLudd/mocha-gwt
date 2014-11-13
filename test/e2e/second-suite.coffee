describe 'second', ->

  Then -> @result == 'foo'
  Given -> @result = 'foo'

  Then -> global.cleanMeUp == undefined
