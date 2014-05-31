CoffeeDocs = require('./coffeedocs')

module.exports =
  configDefaults:
    addReturns: true,
    ReturnsDefaultType: '`undefined`'

  # Public: Package gets activated.
  activate: ->
    atom.workspaceView.command 'coffeedocs:generate', ->
      coffeedocs = new CoffeeDocs()
      coffeedocs.parse()
