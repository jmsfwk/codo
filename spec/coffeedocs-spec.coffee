#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#

CoffeeDocs = require '../lib/coffeedocs'
util = require './util'

describe "CoffeeDocs", ->

  beforeEach ->
    editorView = util.openPath('testfile.txt')
    editor = editorView.getEditor()
    @coffeedocs = new CoffeeDocs()

  it 'detects the lines with functions correctly', ->
    expect(@coffeedocs.isFunctionDef(@editor, 0)).toBe(true)
    expect(@coffeedocs.isFunctionDef(@editor, 1)).toBe(true)
    expect(@coffeedocs.isFunctionDef(@editor, 2)).toBe(true)
    expect(@coffeedocs.isFunctionDef(@editor, 3)).toBe(false)
    expect(@coffeedocs.isFunctionDef(@editor, 4)).toBe(true)
    expect(@coffeedocs.isFunctionDef(@editor, 5)).toBe(true)
    expect(@coffeedocs.isFunctionDef(@editor, 6)).toBe(true)

  it 'returns the right function names', ->
    expect(@coffeedocs.getFunctionDef(@editor, 0).name).toBe('luke')
    expect(@coffeedocs.getFunctionDef(@editor, 1).name).toBe('yoda')
    expect(@coffeedocs.getFunctionDef(@editor, 2).name).toBe('obiwan')
    expect(@coffeedocs.getFunctionDef(@editor, 4).name).toBe('quigon')
    expect(@coffeedocs.getFunctionDef(@editor, 5).name).toBe('windu')
    expect(@coffeedocs.getFunctionDef(@editor, 6).name).toBe('anakin')

  it 'returns the right function arguments or none if there are none', ->
    expect(@coffeedocs.getFunctionDef(@editor, 0).args).toEqual([])
    expect(@coffeedocs.getFunctionDef(@editor, 1).args).toEqual(['arg1'])
    expect(@coffeedocs.getFunctionDef(@editor, 2).args).toEqual(['arg1','arg2','arg3'])
    expect(@coffeedocs.getFunctionDef(@editor, 4).args).toEqual([])
    expect(@coffeedocs.getFunctionDef(@editor, 5).args).toEqual(['arg1'])
    expect(@coffeedocs.getFunctionDef(@editor, 6).args).toEqual(['arg1','arg2','arg3'])