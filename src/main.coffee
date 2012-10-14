$(->

  window.assets = assets = new AssetManager({
    baseUrl: ""
    packs:
      images: [
        {name:"goblin",src:"img/goblin.png"},
        {name:"skeleton",src:"img/skeleton.png"},
        {name:"player",src:"img/player.png"},
        {name:"goblin",src:"img/goblin.png"},
      ]
    preload: false
  })

  assets.on 'complete', 'all', =>
    console.log "asdf"
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

  assets.downloadAll()

)
