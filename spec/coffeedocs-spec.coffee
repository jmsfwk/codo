#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#

CoffeeDocs = require '../lib/coffeedocs'

describe 'CoffeeDocs', ->

  [editor, coffeedocs] = []

  beforeEach ->

    coffeedocs = new CoffeeDocs()

    waitsForPromise ->
      atom.workspace.open('testfile.txt').then (o) -> editor = o

  describe 'when we try to generate function documentation', ->

    it 'detects the lines with functions correctly', ->
      expect(coffeedocs.isFunctionDef(editor, 0)).toBe(true)
      expect(coffeedocs.isFunctionDef(editor, 1)).toBe(true)
      expect(coffeedocs.isFunctionDef(editor, 2)).toBe(true)
      expect(coffeedocs.isFunctionDef(editor, 3)).toBe(false)
      expect(coffeedocs.isFunctionDef(editor, 4)).toBe(true)
      expect(coffeedocs.isFunctionDef(editor, 5)).toBe(true)
      expect(coffeedocs.isFunctionDef(editor, 6)).toBe(true)

    it 'returns the right function names', ->
      expect(coffeedocs.getFunctionDef(editor, 0).name).toBe('luke')
      expect(coffeedocs.getFunctionDef(editor, 1).name).toBe('yoda')
      expect(coffeedocs.getFunctionDef(editor, 2).name).toBe('obiwan')
      expect(coffeedocs.getFunctionDef(editor, 4).name).toBe('quigon')
      expect(coffeedocs.getFunctionDef(editor, 5).name).toBe('windu')
      expect(coffeedocs.getFunctionDef(editor, 6).name).toBe('anakin')

    it 'returns the right function arguments or none if there are none', ->
      expect(coffeedocs.getFunctionDef(editor, 0).args).toEqual([])
      expect(coffeedocs.getFunctionDef(editor, 1).args).toEqual(['arg1'])
      expect(coffeedocs.getFunctionDef(editor, 2).args).toEqual(['arg1','arg2','arg3'])
      expect(coffeedocs.getFunctionDef(editor, 4).args).toEqual([])
      expect(coffeedocs.getFunctionDef(editor, 5).args).toEqual(['arg1'])
      expect(coffeedocs.getFunctionDef(editor, 6).args).toEqual(['arg1','arg2','arg3'])

  describe 'when we try to generate class documentation', ->

    helper = (row) -> coffeedocs.getClassDef(editor, row)

    describe 'when the line contains an anonymous class', ->
      it 'parses it', ->
        expect(helper(7)).toEqual({name: null, 'extends': null})

    describe 'when the line contains a named class', ->
      it 'parses it', ->
        expect(helper(8)).toEqual({name: 'Vader', 'extends': null})

    describe 'when the line contains a named subclass', ->
      it 'parses it', ->
        expect(helper(9)).toEqual({name: 'Vader', 'extends': 'Luke'})
