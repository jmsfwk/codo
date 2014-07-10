#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#

CoffeeDocs = require('./coffeedocs')

module.exports =
  configDefaults:
    addReturns: true,
    ReturnsDefaultType: '`undefined`',
    ReturnsTemplate: 'Returns the %desc% as %type%.'
    SearchLineBelowInstead: false

  # Public: Package gets activated.
  activate: ->
    atom.workspaceView.command 'coffeedocs:generate', ->
      coffeedocs = new CoffeeDocs()
      coffeedocs.parse()
