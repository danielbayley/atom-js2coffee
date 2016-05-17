{allowUnsafeEval} = require 'loophole'
Js2Coffee = allowUnsafeEval -> require 'js2coffee'

{MessagePanelView, LineMessageView} = require 'atom-message-panel'

RangeFinder = require './range-finder'
#workspace = atom.workspace, it is not ready here!
#commands  = atom.commands
messages  = null

newMessagePanelView = ->
  messages = new MessagePanelView
    title: 'js2coffee'
    recentMessagesAtTop: true

module.exports =
  activate: ->
    #atom.workspaceView.command 'js2coffee:toggle', '.editor', =>
    @commands = atom.commands.add 'atom-workspace',
      'js2coffee:convert': (e) ->
        editor = atom.workspace.getActiveTextEditor()
        convertJs(editor)
      'js2coffee:messages': (e) ->
        if messages.panel? and messages.panel.isVisible()
          messages.close()
        else
          messages.attach()
    newMessagePanelView()

  deactivate: ->
    @commands.dispose()
    if messages
      messages.dispose()
      messages = null

  convert: convertJs = (editor) ->
    messages.clear()
    ranges = RangeFinder.rangesFor(editor)
    ranges.forEach (range) ->
      jsContent = editor.getTextInBufferRange(range)
      try
        result = Js2Coffee.build jsContent,
          indent: editor.getTabText()
          filename: editor.getTitle()
      catch e
        console.error('invalid javascript:%s', e.message)
        messages.add new LineMessageView
          line: range.start.row + e.start.line
          character: e.start.column
          message: 'error:' + e.message #+ "\n"+ e.description
          preview: e.sourcePreview

      if result
        if result.warnings
          result.warnings.forEach (e) ->
            messages.add new LineMessageView
              line: range.start.row + e.start.line
              character: e.start.column
              message: 'warning:' + e.description
              #preview: e.sourcePreview
        if result.code
          editor.setTextInBufferRange(range, result.code)
    if not (messages.panel? and messages.panel.isVisible()) and
       messages.messages.length
      messages.attach()
