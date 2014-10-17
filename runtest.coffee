Mocha = require 'mocha'
fs = require 'fs'
path = require 'path'
require './lib/mocha-gwt'
testDir = 'test'
mocha = new Mocha
  reporter: 'dot'
  ui: 'mocha-gwt'

mocha.addFile './e2etest.coffee'

mocha.run (failures) ->
  process.on 'exit', ->
    process.exit failures
