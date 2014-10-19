Promise = require 'bluebird'

describe 'mocha-gwt', ->
  append = (char) => -> @result += char
  resultIs = (expected) => -> @result == expected

  Given ->
    @result = ''
  Given append 'a'
  When append 'b'
  Then resultIs 'ab'

  describe 'nested given', ->
    Given append '1'
    Then resultIs 'a1b'

    describe '- no givens or thens added', ->
      Then resultIs 'a1b'

    describe 'just when', ->
      When append 'c'
      Then resultIs 'a1bc'

    describe 'sibling when', ->
      When append 'c'
      Then resultIs 'a1bc'

  describe 'outer after inner', ->
    Then resultIs 'ab'

  describe 'a then that changes the result', ->
    Then -> @result = 42

    describe 'does not affect nested givens/whens', ->
      Given append 'z'
      When append 'x'
      Then resultIs 'azbx'

  describe 'async support', ->
    Given (done) ->
      setTimeout =>
        @result += '1'
        done()
      , 1
    When (done) ->
      setTimeout =>
        @result += '2'
        done()
      , 1
    Then -> @result == 'a1b2'

  describe 'promise support', ->
    Given -> Promise.resolve => @result += '1'
    When -> Promise.resolve => @result += '2'
    Then -> @result = 'a1b2'
