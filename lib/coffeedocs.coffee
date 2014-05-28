module.exports =
class CoffeeDocs

  # Public: Returns the setting under the key 'key'.
  #
  # key - The config key as {String}.
  #
  # Returns: Returns the value of config key.
  getConfig: (key) ->
    switch key
      when "addReturns" then atom.config.get("coffeedocs.addReturns")
      when "ReturnsDefaultType" then atom.config.get("coffeedocs.ReturnsDefaultType")
      else null

  # Public: Get the active Editor.
  #
  # Returns: The active Editor.
  getEditor: -> atom.workspace.getActiveEditor()

  # Public: Returns the function definition from row n.
  #
  # editor - The Editor to read from.
  # n      - The row number to read from.
  #
  # Returns: The function definition as {Object}:
  #   :name - The name of the function as {String}.
  #   :args - The arguments of the function as {Array}.
  getFunctionDef: (editor, n) ->
    return unless @isFunctionDef(editor, n)

    regex = /[a-zA-Z_$][a-zA-Z_$0-9]*=?\w*/g
    line = @readLine(editor, n)
    line = @readLine(editor, n)?.split('->')[0].split('=>')[0]
    line = line?.match(regex)
    return unless line.length >= 1

    functionName = line[0]
    functionArgs = if line.length > 1 then line[1..] else functionArgs=[]

    return {name: functionName, args: functionArgs}

  # Public: Checks if the active line defines a function.
  #
  # editor - The Editor to check from.
  # n      - The row {Number} to check.
  #
  # Returns: {Boolean}
  isFunctionDef: (editor, n) ->
    regex = /\s*[a-zA-Z_$@][a-zA-Z_$0-9]*:.*([-=]>).*/
    line = @readLine(editor, n)
    regex.test(line)

  # Public: Read the specified line.
  #
  # editor - The Editor to read from. If not set, use the active Editor.
  # n      - The row {Number} to read from.
  #
  # Returns: The line as {String}.
  readLine: (editor, n) ->
    editor = @getEditor() unless editor?
    return editor.getCursor()?.getCurrentBufferLine() unless n?
    editor.lineForBufferRow(n)

  # Public Static: Parse the active line.
  parse: ->
    editor = @getEditor()
    return unless editor?

    linePos = editor.getCursorScreenRow()
    functionDef = @getFunctionDef(editor, linePos)
    return unless functionDef?

    snippet = @generateSnippetFunc(functionDef)
    @writeSnippet(editor, snippet)

  # Public: Write a snippet into active editor using the snippets package.
  #
  # editor - The Editor the snippet gets activated in.
  # str    - The {String} containing the snippet code.
  writeSnippet: (editor, str) ->
    return if not editor? or not str?
    editor?.insertNewlineAbove()

    Snippets = atom.packages.activePackages.snippets.mainModule;
    Snippets?.insert(str, editor)

  # Public: Generates a suitable snippet base on the functionDef.
  #
  # functionDef - The {Object} with the function definition:
  #   :name - {String} with name of the function.
  #   :args - {Array} with function arguments.
  #
  # Returns: The generated snippet as {String}.
  generateSnippetFunc: (functionDef) ->
    functionName = functionDef.name
    functionArgs = functionDef.args

    snippet = """
      # ${1:Public:} ${2:[Description]}
    """
    snippetIndex = 3

    if functionArgs.length>=1
      snippet += "\n#"

      functionArgs = @indentFunctionArgs(functionArgs)
      for arg in functionArgs
        snippet += "\n# #{arg} - The {${#{snippetIndex}:[type]}} ${#{snippetIndex+1}:[description]}"
        snippetIndex = snippetIndex+2

    if @getConfig("addReturns")
      snippet += "\n#\n# Returns: ${#{snippetIndex}:" + @getConfig("ReturnsDefaultType") + "}"
    snippet += "$0"
    return snippet

  # Public: Indentates the arguments and removes default values.
  #
  # args - The {Array} containing the function arguments.
  #
  # Returns: The indented arguments as {Array}.
  indentFunctionArgs: (args) ->
    maxLength = 1
    for arg, i in args
      arg = args[i] = arg.split('=')[0]
      if arg.length > maxLength
        maxLength = arg.length

    for arg, i in args
      args[i] = @appendWhitespaces(arg, maxLength-arg.length)

    return args

  # Public: Appends n whitespaces to str.
  #
  # str - The {String} to append to.
  # n   - The amount of whitespaces to append.
  #
  # Returns: str as {String} with appended whitespaces.
  appendWhitespaces: (str, n) ->
    return str if n<1
    str += " " for [0...n]
    return str
