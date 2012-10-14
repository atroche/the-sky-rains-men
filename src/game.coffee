class Game

  FPS: 60

  constructor: (assets) ->
    @lastUpdate = Date.now()

    @keysDown = {}

    $("body").keydown (e) =>
      @keysDown[e.keyCode] = true

      normalKey = not (e.ctrlKey or e.altKey or e.shiftkey or e.metaKey)
      movementKey = e.keyCode in [37, 39]

      if e.keyCode == 80 # p / P
        @togglePaused()

      if normalKey
        e.preventDefault()
        if not movementKey and @world.gameOver()
          @world.reset()

    $("body").keyup (e)   =>
      delete @keysDown[e.keyCode]
      if e.keyCode in [37, 39]
        e.preventDefault()

    @world = new World(assets)

    bg_music = new Audio("audio/bg_music.mp3")
    bg_music.loop = true
    bg_music.addEventListener 'canplaythrough', ->
      bg_music.play()

  main: =>
    delta = Date.now() - @lastUpdate

    unless @paused
      @update(delta)
      @render()

    @lastUpdate = Date.now()

  reactToInput: (delta) ->
    if 37 of @keysDown
      @world.player.moveLeft(delta)
    else if 39 of @keysDown
      @world.player.moveRight(delta)
    else if 82 of @keysDown # r / R
      @reset()
    else
      @world.player.moveToCentre(delta)

  update: (delta) ->
    @reactToInput(delta)
    @world.update(delta)

  render: ->
    @world.render()

  run: ->
    setInterval(@main, 1000 / @FPS)

  setPlayerSpeed: (speed) =>
    @world.playerSpeed = speed

  toggleShowHitBoxes: (state) =>
    @world.showHitBoxes = state

  reset: =>
    @world.reset()

  togglePaused: ->
    @paused = not @paused

window.Game = Game