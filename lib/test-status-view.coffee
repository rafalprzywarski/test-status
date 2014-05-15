{View}  = require 'atom'

Convert = require 'ansi-to-html'

module.exports =
# Internal: A tool-panel view for the test result output.
class TestStatusView extends View

  # Internal: Initialize test-status output view DOM contents.
  @content: ->
    @div tabIndex: -1, class: 'test-status-output tool-panel panel-bottom padded native-key-bindings', =>
      @div class: 'block', =>
        @div class: 'message', outlet: 'testStatusOutput'

  # Internal: Initialize the test-status output view and event handlers.
  initialize: ->
    @output = "<strong>No output</strong>"
    @testStatusOutput.html(@output).css('font-size', "#{atom.config.getInt('editor.fontSize')}px")

    atom.workspaceView.command "test-status:toggle-output", =>
      @toggle()

  createFileLink: (fileLine, links) ->
    links.push fileLine
    return "<a href='#' style='color: lightblue'>#{fileLine}</a>";

  attachLinks: (links) ->
    for link in links
      do (link) =>
        @testStatusOutput.find("a:contains('#{link}')").click(() =>
          pathAndLine = link.split(":")
          p = atom.workspace.open(pathAndLine[0])
          p.then((editor) =>
            editor.setCursorBufferPosition([parseInt(pathAndLine[1], 10) - 1, 0])))

  # Internal: Update the test-status output view contents.
  #
  # output - A string of the test runner results.
  #
  # Returns nothing.
  update: (output) ->
    @convert ?= new Convert({newline: true})
    links = []
    @output = @convert.toHtml(
      output.replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/([\.\/]?\/?([\w\.\+]+\/)+[\w\.\+]+):(\d+)(:\d+)?/g, (match) => @createFileLink(match, links))
      )
    @testStatusOutput.html("<pre>#{@output.trim()}</pre>")
    @testStatusOutput.scrollTop(@testStatusOutput[0].scrollHeight)
    @attachLinks(links)

  # Internal: Detach and destroy the test-status output view.
  #
  # Returns nothing.
  destroy: ->
    @detach()

  # Internal: Toggle the visibilty of the test-status output view.
  #
  # Returns nothing.
  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.prependToBottom(this) unless @hasParent()
