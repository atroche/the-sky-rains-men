class Game

  FPS: 60

  constructor: (assets) ->
    @world = new World(assets)

    @lastUpdate = Date.now()

    @keysDown = {}

    moveToTouch = (touchEvent) =>
      touch = touchEvent.changedTouches[0]

      @world.player.tryToMoveTo touch.pageX

      return false

    resetOnTap = (touchEvent) =>
      if @world.gameOver()
        @world.reset()

      return false

    @world.canvas.addEventListener 'touchstart', moveToTouch
    @world.canvas.addEventListener 'touchstart', resetOnTap

    @world.canvas.addEventListener 'touchmove', moveToTouch

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

    bg_music = new Audio("audio/bg_music.mp3")
    bg_music.loop = true
    bg_music.addEventListener 'canplaythrough', ->
      # bg_music.play()

  main: =>
    delta = Date.now() - @lastUpdate

    unless @paused
      @update(delta)
      @render()

    @lastUpdate = Date.now()

  update: (delta) ->
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