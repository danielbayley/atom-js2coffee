fs = require 'fs'
path = require 'path'
temp = require 'temp'

Js2coffee = require '../lib/js2coffee'
helper = require './spec-helper'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe 'Js2coffee', ->
  #activationPromise = null
  [buffer, directory, editor, filePath, workspaceElement, activationPromise] = []
  editorView = null

  beforeEach ->
    expect(atom.packages.isPackageActive('js2coffee')).toBe false
    directory = temp.mkdirSync()
    atom.project.setPaths(directory)
    workspaceElement = atom.views.getView(atom.workspace)
    filePath = path.join(directory, 'testjs2coffee.txt')
    fs.writeFileSync(filePath, '')
    atom.config.set('editor.tabLength', 2)
    #atom.workspaceView = new WorkspaceView
    #activationPromise = atom.packages.activatePackage('js2coffee')

    waitsForPromise ->
      atom.workspace.open(filePath).then (e) -> editor = e
    waitsForPromise ->
      atom.packages.activatePackage('js2coffee')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)
      buffer = editor.getBuffer()

      #activationPromise = atom.packages.activatePackage('js2coffee')
      #activationPromise.fail (reason) -> throw reason

  ###
  describe 'Before Activation', ->
    it 'should not be active', ->
      expect(atom.packages.isPackageActive('js2coffee')).toBe false
    it 'actived here', ->
      atom.commands.dispatch editorView, 'js2coffee:toggle'
      waitsForPromise -> activationPromise
  ###
  describe 'activate', ->
    it 'should create the commands', ->
      expect(helper.hasCommand(workspaceElement, 'js2coffee:convert')).toBeTruthy()

  describe 'js2coffee', ->
    beforeEach ->
    it 'should convert a js to coffee', ->
      buffer.setText '
        var a = 123;
        var b = "2323";
      '
      atom.commands.dispatch(workspaceElement, 'js2coffee:convert')
      expect(editor.getText().trim()).toBe "a = 123\nb = '2323'"

  ###
  describe 'deactivate', ->
    beforeEach ->
      atom.packages.deactivatePackage('js2coffee')

    it 'destroys the commands', ->
      expect(helper.hasCommand(workspaceElement, 'js2coffee:toggle')).toBeFalsy()
  ###
