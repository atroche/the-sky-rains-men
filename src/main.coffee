$(->

  document.ontouchstart = (e) ->
      e.preventDefault()

  document.ontouchmove = (e) ->
      e.preventDefault()

  window.assets = assets = new AssetManager({
    baseUrl: ""
    packs:
      core: [
        {name: "goblin", src: "img/goblin.png"},
        {name: "skeleton", src: "img/skeleton.png"},
        {name: "player", src: "img/player.png"},
        {name: "goblin", src: "img/goblin.png"},
        {name: "bat", src: "img/bat.png"},
        {name: "wizard", src: "img/wizard.png"},
        {name: "treasure", src: "img/treasure.png"},
        {name: "lostLife", src: "audio/lostLife.wav"},
        {name: "sword1", src: "audio/sword1.wav"},
        {name: "sword2", src: "audio/sword2.wav"},
        {name: "sword3", src: "audio/sword3.wav"},
        {name: "sword4", src: "audio/sword4.wav"},
        {name: "dying", src: "audio/dying.wav"}
      ]
    preload: false
  })

  assets.on 'complete', 'all', =>
    console.log "asdf"
    game = new Game(assets)
    game.run()

    Settings = ->
      this.reset = ->
        game.reset()

      this.initialSpeed = game.world.initialSpeed
      this.playerSpeed = game.world.player.speed
      this.acceleration = game.world.acceleration
      this.showHitBoxes = game.world.showHitBoxes

    settings = new Settings
    gui = new dat.GUI()

    initialSpeed = gui.add(settings, 'initialSpeed', 100, 500)
    initialSpeed.onChange(game.setInitialSpeed)

    acceleration = gui.add(settings, 'acceleration', .1, 3)
    acceleration.onChange(game.setAcceleration)

    playerSpeed = gui.add(settings, 'playerSpeed', .1, 3)
    playerSpeed.onChange(game.setPlayerSpeed)

    showHitBoxes = gui.add(settings, 'showHitBoxes')
    showHitBoxes.onChange(game.toggleShowHitBoxes)

    reset = gui.add(settings, 'reset')

  assets.downloadAll()

)
