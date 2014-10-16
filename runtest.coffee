Mocha = require 'mocha'
fs = require 'fs'
path = require 'path'
require './lib/mocha-gwt'
testDir = 'test'
mocha = new Mocha
  reporter: 'spec'
  ui: 'mocha-gwt'

fs.readdirSync(testDir).filter((file) ->
  file.match /\.(coffee|js)$/
).forEach (file) ->
  mocha.addFile path.join(testDir, file)

mocha.run (failures) ->
  process.on 'exit', ->
    process.exit failures
