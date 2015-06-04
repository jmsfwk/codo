#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#

CoffeeDocs = require './coffeedocs'

module.exports =
  config:
    addReturns:
      type: 'boolean',
      default: true
    ReturnsDefaultType:
      type: 'string',
      default: '`undefined`',
    ReturnsTemplate:
      type: 'string',
      default: 'Returns the %desc% as %type%.'
    SearchLineBelowInstead:
      type: 'boolean',
      default:false

  # Public: Package gets activated.
  activate: ->
    atom.commands.add 'atom-text-editor',
      'coffeedocs:generate': ->
        coffeedocs = new CoffeeDocs()
        coffeedocs.parse()
