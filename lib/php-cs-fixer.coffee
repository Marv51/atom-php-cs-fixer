{CompositeDisposable} = require 'atom'
{BufferedProcess} = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports = PhpCsFixer =
  subscriptions: null
  config:
    phpExecutablePath:
      type: 'string'
      default: 'php'
      description: 'the path to the `php` executable'
    executablePath:
      type: 'string'
      default: '~/.composer/vendor/bin/php-cs-fixer'
      description: 'the path to the `php-cs-fixer` executable'
    level:
      type: 'string'
      enum: ['psr0', 'psr1', 'psr2', 'symfony']
      default: 'psr2'
      description: 'for example: psr0, psr1, psr2 or symfony'
    fixers:
      type: 'string'
      default: ''
      description: 'a list of fixers, for example: `linefeed,short_tag,indentation`. See <http://cs.sensiolabs.org/#usage> for a complete list'
    executeOnSave:
      type: 'boolean'
      default: false
      description: 'execute PHP CS fixer on save'

  activate: (state) ->
    atom.config.observe 'php-cs-fixer.executeOnSave', =>
      @executeOnSave = atom.config.get 'php-cs-fixer.executeOnSave'

    atom.config.observe 'php-cs-fixer.phpExecutablePath', =>
      @phpExecutablePath = atom.config.get 'php-cs-fixer.phpExecutablePath'

    atom.config.observe 'php-cs-fixer.executablePath', =>
      @executablePath = atom.config.get 'php-cs-fixer.executablePath'

    atom.config.observe 'php-cs-fixer.level', =>
      @level = atom.config.get 'php-cs-fixer.level'

    atom.config.observe 'php-cs-fixer.fixers', =>
      @fixers = atom.config.get 'php-cs-fixer.fixers'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'php-cs-fixer:fix': => @fix()
    @subscriptions.add atom.commands.add 'atom-workspace', 'php-cs-fixer:fixProject': => @fixProject()

    # Add workspace observer and save handler
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.getBuffer().onWillSave =>
        if editor.getGrammar().name == "PHP" and @executeOnSave
          @fix()

  deactivate: ->
    @subscriptions.dispose()

  fixProject: ->
    console.log "fixProject"
    paths = atom.project.getPaths()
    @fixDir path for path in paths

  fixDir: (path) ->
    command = @phpExecutablePath

    # init options
    args = [@executablePath, 'fix', path]

    configPath = false
    #if configPath = @findFile(path, '.php_cs')
    #  args.push '--config-file=' + configPath

    # add optional options
    args.push '--level=' + @level if @level and not configPath
    args.push '--fixers=' + @fixers if @fixers and not configPath

    # some debug output for better support feedback
    console.debug('php-cs-fixer Command', command)
    console.debug('php-cs-fixer Arguments', args)

    outputPanel = document.createElement("div");
    outputPanel.innerText = "Fixer running."
    options = {};
    options.item = outputPanel;

    modalPanel = atom.workspace.addModalPanel(options);

    stdout = (output) ->
      #Show a warning for everything that doesn't start with "Fixed..."
      if (!/^\s*\d*\).*\.php/.test(output))
        atom.notifications.addInfo(output)
      outputElement = document.createElement("p")
      outputElement.innerText = output
      outputPanel.appendChild(outputElement);
      console.log(output)
    stderr = (output) ->
      atom.notifications.addError(output)
      console.error(output)
    exit = (code) ->
      console.log("#{command} exited with code: #{code}")
      modalPanel.hide()
      modalPanel.destroy()

    process = new BufferedProcess({
      command: command,
      args: args,
      stdout: stdout,
      stderr: stderr,
      exit: exit
    }) if path

  fix: ->
    editor = atom.workspace.getActivePaneItem()

    filePath = editor.getPath() if editor && editor.getPath

    command = @phpExecutablePath

    # init options
    args = [@executablePath, 'fix', filePath]

    # if configPath = @findFile(path.dirname(filePath), '.php_cs')
    #  args.push '--config-file=' + configPath

    # add optional options
    args.push '--level=' + @level if @level and not configPath
    args.push '--fixers=' + @fixers if @fixers and not configPath

    # some debug output for better support feedback
    console.debug('php-cs-fixer Command', command)
    console.debug('php-cs-fixer Arguments', args)
    stdout = (output) ->
      #Show a warning for everything that doesn't start with "Fixed..."
      if (!/^Fixed/.test(output))
        atom.notifications.addWarning(output)
      console.log(output)
    stderr = (output) ->
      atom.notifications.addError(output)
      console.error(output)
    exit = (code) -> console.log("#{command} exited with code: #{code}")
    process = new BufferedProcess({
      command: command,
      args: args,
      stdout: stdout,
      stderr: stderr,
      exit: exit
    }) if filePath

  # copied from the AtomLinter lib
  # see: https://github.com/AtomLinter/atom-linter/blob/master/lib/helpers.coffee#L112
  #
  # The AtomLinter is licensed under "The MIT License (MIT)"
  #
  # Copyright (c) 2015 AtomLinter
  #
  # See the full license here: https://github.com/AtomLinter/atom-linter/blob/master/LICENSE
  findFile: (startDir, names) ->
    throw new Error "Specify a filename to find" unless arguments.length
    unless names instanceof Array
      names = [names]
    startDir = startDir.split(path.sep)
    while startDir.length
      currentDir = startDir.join(path.sep)
      for name in names
        filePath = path.join(currentDir, name)
        try
          fs.accessSync(filePath, fs.R_OK)
          return filePath
      startDir.pop()
    return null
