path = require 'path'
glob = require 'glob'

module.exports =

# Internal: Describes the package configuration.
#
# Properties:
#
# buildCommand: build command for the current project
class CommandRunnerConfiguration
  constructor: (@cfg) ->
    @buildCommand = null
    @parseConfiguration(cfg)

  matchBuildCommand: (file) ->
    pattern = path.join(atom.project.path, file)
    matches = glob.sync(pattern)
    return null if matches.length is 0
    @cfg[file]

  parseConfiguration: ->
    for key in Object.keys(@cfg)
      @buildCommand = @matchBuildCommand(key) unless @buildCommand
