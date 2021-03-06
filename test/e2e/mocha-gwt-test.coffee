Promise = require 'bluebird'

describe 'mocha-gwt', ->
  append = (char) => -> @result += char
  resultIs = (expected) => -> @result == expected
  beforeAllCheck = 1

  beforeAll ->
    global.cleanMeUp = 'dirty'
    if beforeAllCheck++ > 1
      throw new Error 'Before all was called more than once'

  afterAll ->
    global.cleanMeUp = undefined

  Given -> @result = ''
  Given append 'a'
  When append 'b'
  Then resultIs 'ab'
  Invariant -> beforeAllCheck == 2

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

  Then resultIs 'ab'

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
    Given -> Promise.resolve().then => @result += '1'
    When -> Promise.resolve().then => @result += '2'
    Then -> @result == 'a1b2'

  xdescribe 'ignored should not be called', ->
    Given -> throw new Error 'should not reach this given'
    When -> throw new Error 'should not reach this when'
    Then -> throw new Error 'should not reach this then'
    And -> throw new Error 'should not reach this and'

    describe 'and neither their children', ->
      Given -> throw new Error 'should not reach child given'
      When -> throw new Error 'should not reach child when'
      Then -> throw new Error 'should not reach child then'
      And -> throw new Error 'should not reach child and'

  describe 'after is called after its block', ->
    foo = undefined
    thisFoo = undefined
    Given -> foo = 1 unless foo?
    Given -> @localFoo = 'foo'
    Then -> foo == 1
    afterBlock -> foo = 2
    afterBlock -> @localFoo == 'foo'

    describe 'after should have been called', ->
      Then -> foo == 2

  describe 'aliases', ->
    Then -> global.context == describe
    Then -> global.context.skip == describe.skip
    And  -> global.xcontext == describe.skip
    Then -> global.context.only == describe.only
    And  -> global.ccontext == describe.only
