CoffeeDocs = require('./coffeedocs')

module.exports =
  configDefaults:
    addReturns: false

  # Public: Package gets activated.
  activate: ->
    atom.workspaceView.command "coffeedocs:generate", =>
      coffeedocs = new CoffeeDocs()
      coffeedocs.parse()
