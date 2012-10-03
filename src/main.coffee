$(->
  game = new Game
  game.run()

  Settings = ->
    this.reset = ->
      game.reset()

    this.playerSpeed = game.world.player.speed
    this.showHitBoxes = game.world.showHitBoxes

  settings = new Settings
  gui = new dat.GUI()

  playerSpeed = gui.add(settings, 'playerSpeed', .1, 2)
  playerSpeed.onChange(game.setPlayerSpeed)

  showHitBoxes = gui.add(settings, 'showHitBoxes')
  showHitBoxes.onChange(game.toggleShowHitBoxes)

  reset = gui.add(settings, 'reset')

)
