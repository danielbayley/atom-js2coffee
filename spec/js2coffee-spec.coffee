fs = require 'fs'
path = require 'path'
temp = require 'temp'

helper = require './spec-helper'

describe 'js2coffee', ->
  [buffer, directory, editor, filePath, workspaceElement] = []
  editorView = null

  beforeEach ->
    expect(atom.packages.isPackageActive 'js2coffee').toBe false

    directory = temp.mkdirSync()
    atom.project.setPaths directory
    workspaceElement = atom.views.getView atom.workspace
    filePath = path.join directory, 'testjs2coffee.txt'
    fs.writeFileSync filePath, ''
    atom.config.set('editor.tabLength', 2)

    waitsForPromise ->
      atom.workspace.open(filePath).then (e) -> editor = e
    waitsForPromise ->
      atom.packages.activatePackage 'js2coffee'
    runs ->
      expect(atom.packages.isPackageActive 'js2coffee').toBe true
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView editor
      buffer = editor.getBuffer()

  describe 'activate', ->
    it 'should create the commands', ->
      expect(helper.hasCommand workspaceElement, 'js2coffee:convert').toBeTruthy()
      expect(helper.hasCommand workspaceElement, 'js2coffee:messages').toBeTruthy()

  describe 'convert', ->
    it 'should convert js to coffee', ->
      buffer.setText '
        var a = 123;
        var b = "2323";
      '
      atom.commands.dispatch workspaceElement, 'js2coffee:convert'
      expect(editor.getText().trim()).toBe "a = 123\nb = '2323'"

  describe 'deactivate', ->
    beforeEach ->
      atom.packages.deactivatePackage 'js2coffee'

    it 'is deactivated', ->
      expect(atom.packages.isPackageActive 'js2coffee').toBe false

    it 'unloads the commands', ->
      expect(helper.hasCommand workspaceElement, 'js2coffee:convert').toBeFalsy()
