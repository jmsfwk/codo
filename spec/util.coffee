#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#

{WorkspaceView} = require 'atom'

module.exports = {
  openPath: (path) ->
    fullPath = atom.project.resolve(path)

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()
    atom.workspaceView.openSync(fullPath)

    atom.workspaceView.getActiveView()
}
