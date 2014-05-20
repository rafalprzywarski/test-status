path = require 'path'
glob = require 'glob'

module.exports =

# Internal: Describes the package configuration.
#
# Properties:
#
# hasLiveUpdate: has live update of executed command output
# buildCommand: build command for the current project
class CommandRunnerConfiguration
  constructor: (@cfg) ->
    @buildCommand = null
    @parseConfiguration(cfg)

  hasLiveUpdate: ->
    @cfg['live-update'] is true

  isOption: (key) ->
    key is 'live-update'

  matchBuildCommand: (file) ->
    pattern = path.join(atom.project.path, file)
    matches = glob.sync(pattern)
    return null if matches.length is 0
    @cfg[file]

  parseConfiguration: ->
    for key in Object.keys(@cfg)
      continue if @isOption(key)
      @buildCommand = @matchBuildCommand(key) unless @buildCommand
