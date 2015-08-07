#
# Copyright (c) 2015 by James Fenwick. See LICENSE for details.
#

Codo = require './codo'

module.exports =
  config:
    addReturns:
      type: 'boolean',
      default: true
    ReturnsDefaultType:
      type: 'string',
      default: 'undefined',
    ReturnsTemplate:
      type: 'string',
      default: '@return %type% %desc%'
    SearchLineBelowInstead:
      type: 'boolean',
      default:false

  # Public: Package gets activated.
  activate: ->
    atom.commands.add 'atom-text-editor',
      'codo:generate': ->
        Codo = new Codo()
        Codo.parse()
