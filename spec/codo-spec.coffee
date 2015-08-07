#
# Copyright (c) 2015 by James Fenwick. See LICENSE for details.
#

Codo = require '../lib/codo'

describe 'codo', ->

  [editor, codo] = []

  beforeEach ->

    codo = new Codo()

    waitsForPromise ->
      atom.workspace.open('testfile.txt').then (o) -> editor = o

  describe 'when we try to generate function documentation', ->

    it 'detects the lines with functions correctly', ->
      expect(codo.isFunctionDef(editor, 0)).toBe(true)
      expect(codo.isFunctionDef(editor, 1)).toBe(true)
      expect(codo.isFunctionDef(editor, 2)).toBe(true)
      expect(codo.isFunctionDef(editor, 3)).toBe(false)
      expect(codo.isFunctionDef(editor, 4)).toBe(true)
      expect(codo.isFunctionDef(editor, 5)).toBe(true)
      expect(codo.isFunctionDef(editor, 6)).toBe(true)

    it 'returns the right function names', ->
      expect(codo.getFunctionDef(editor, 0).name).toBe('luke')
      expect(codo.getFunctionDef(editor, 1).name).toBe('yoda')
      expect(codo.getFunctionDef(editor, 2).name).toBe('obiwan')
      expect(codo.getFunctionDef(editor, 4).name).toBe('quigon')
      expect(codo.getFunctionDef(editor, 5).name).toBe('windu')
      expect(codo.getFunctionDef(editor, 6).name).toBe('anakin')

    it 'returns the right function arguments or none if there are none', ->
      expect(codo.getFunctionDef(editor, 0).args).toEqual([])
      expect(codo.getFunctionDef(editor, 1).args).toEqual(['arg1'])
      expect(codo.getFunctionDef(editor, 2).args).toEqual(['arg1','arg2','arg3'])
      expect(codo.getFunctionDef(editor, 4).args).toEqual([])
      expect(codo.getFunctionDef(editor, 5).args).toEqual(['arg1'])
      expect(codo.getFunctionDef(editor, 6).args).toEqual(['arg1','arg2','arg3'])

  describe 'when we try to generate class documentation', ->

    helper = (row) -> codo.getClassDef(editor, row)

    describe 'when the line contains an anonymous class', ->
      it 'parses it', ->
        expect(helper(7)).toEqual({name: null, 'extends': null})

    describe 'when the line contains a named class', ->
      it 'parses it', ->
        expect(helper(8)).toEqual({name: 'Vader', 'extends': null})

    describe 'when the line contains a named subclass', ->
      it 'parses it', ->
        expect(helper(9)).toEqual({name: 'Vader', 'extends': 'Luke'})
