$(->
  game = new Game
  game.run()

  Settings = ->
    this.reset = ->
      game.reset()
    this.playerSpeed = game.world.player.speed

  settings = new Settings
  gui = new dat.GUI()

  playerSpeed = gui.add(settings, 'playerSpeed', .1, 2)
  playerSpeed.onChange(game.setPlayerSpeed)

  reset = gui.add(settings, 'reset')

)




class Game

  FPS: 60

  constructor: ->
    @lastUpdate = Date.now()

    @keysDown = {}

    $("body").keydown (e) =>
      @keysDown[e.keyCode] = true

      normalKey = not (e.ctrlKey or e.altKey or e.shiftkey or e.metaKey)
      movementKey = e.keyCode in [37, 39]

      if normalKey
        e.preventDefault()
        if not movementKey and @world.gameOver()
          @world.reset()

    $("body").keyup (e)   =>
      delete @keysDown[e.keyCode]
      if e.keyCode in [37, 39]
        e.preventDefault()

    @world = new World

  main: =>
    delta = Date.now() - @lastUpdate
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

  reset: =>
    @world.reset()



class World

  height: 500
  width: 500
  laneLineWidth: 10
  leftBoundary: 0
  rightBoundary: 500
  numLanes: 3
  lives: 3

  constructor: ->
    @elapsedTime = 0

    @laneWidth = (@width / @numLanes)

    @timeSinceLastThingFell = 2000

    @canvas = document.getElementById('game')
    @canvas.width = 1024
    @canvas.height = 860

    @ctx = @canvas.getContext('2d')
    @ctx.webkitImageSmoothingEnabled = false
    @ctx.font = "bold 16pt Arial"

    @player = new Player(this)

    @objects = [@player]

    @dyingSound = new Audio("audio/dying.wav")

  aliveObjects: ->
    return (object for object in @objects when object.dead isnt true)

  reset: ->
    @elapsedTime = 0
    @timeSinceLastThingFell = 2000

    @player = new Player(this)
    @objects = [@player]

    @lives = 3

  update: (delta) ->
    if @gameOver()
      return

    @elapsedTime += delta
    @timeSinceLastThingFell += delta

    if @timeSinceLastThingFell >= 600
      @objects.push (new FallingThing(this))
      @timeSinceLastThingFell = 0

    object.update(delta) for object in @aliveObjects()

  render: ->
    # clear canvas for redrawing!
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)

    @drawLanes()
    @drawLives()
    @drawTimer()

    if @gameOver()
      @promptReplay()
    else
      object.render() for object in @aliveObjects()

  gameOver: ->
    return @lives <= 0

  promptReplay: ->
    @ctx.fillText("Press any key to play again", @width + 50, 120)

  drawLanes: ->

    laneHeight = @height - 50

    laneX = 0
    while laneX <= @width
      @ctx.fillStyle = "white"
      @ctx.fillRect(laneX, 10, @laneLineWidth, laneHeight)
      laneX += @laneWidth

  middleOfLane: (laneNum) =>
    return @laneLineWidth / 2 + (laneNum - 1) * @laneWidth + @laneWidth / 2

  drawLives: ->
    @ctx.fillText(@lives, @width + 50, 60)

  drawTimer: ->
    @secondsSinceStart = (@elapsedTime / 1000).toFixed(2)

    @ctx.fillText(@secondsSinceStart, @width + 50, 90)


class Entity

  render: ->
    unless @dead
      @sprite.draw(@x, @y)

  destroy: ->
    @dead = true

  centreOn: (centreX) ->
    @x = centreX - (@width / 2)

  centre: ->
    return @x + @width / 2

  # via https://github.com/mdlawson/rogue/blob/master/src/collision.coffee#L3
  isCollidingWith: (otherEntity) ->
    w = (@width + otherEntity.width)/ 2
    h = (@height + otherEntity.height) / 2

    # x and y distance between entities
    dx = (@x + @width / 2) - (otherEntity.x + otherEntity.width / 2)
    dy = (@y + @height / 2) - (otherEntity.y + otherEntity.height / 2)

    if Math.abs(dx) <= w and Math.abs(dy) <= h
      wy = w * dy
      hx = h * dx

      if wy > hx
        if wy > -hx then dir = "top" else dir = "left"
      else
        if wy > -hx then dir = "right" else dir ="bottom"

      px = w - (if dx < 0 then -dx else dx)
      py = h - (if dy < 0 then -dy else dy)
      return {"dir": dir,"pv": [(if dx < 0 then -px else px),(if dy < 0 then -py else py)]}
    return false


class FallingThing extends Entity

  y: 10
  speed: 3
  usedUpALife: false

  constructor: (@world, @lane) ->
    @sprite = new SpriteImage(@world, "orc.png")
    @lostLifeSound = new Audio("audio/lostLife.wav")

    @height = @sprite.image.height - 10
    @width = @world.width / 18

    # a la Python's random.choice
    @lane = Math.floor(Math.random() * @world.numLanes) + 1

    @centreOn (@world.middleOfLane @lane)

  update: (delta) ->
    @y += delta * @speed * Math.log(@world.elapsedTime) / 50

    atPlayersHeight = @y + @height > @world.player.y
    inSameLaneAsPlayer = @lane == @world.player.lane

    if @isCollidingWith @world.player
      @destroy()

    if not @usedUpALife and @y > @world.player.y + 30
      @world.lives -= 1
      if @world.gameOver()
        @world.dyingSound.play()
      @usedUpALife = true
      @lostLifeSound.play()


class Player extends Entity

  constructor: (@world) ->
    @lane = 2
    @y = @world.height

    @speed = @world.playerSpeed || .7
    @returnSpeed = @world.returnSpeed || 1.5

    @width = @world.width / 12
    @height = 10

    @sprite = new SpriteImage(@world, "nyancat.png")

    @centreOn (@world.middleOfLane 2)

  update: (delta) ->
    if @world.gameOver()
      @dyingSound.play()
      @destroy()

  leftOfCentre: ->
    @centre() <= @world.middleOfLane 2

  rightOfCentre: ->
    @centre() >= @world.middleOfLane 2

  moveLeft: (delta) ->
    newPos = @x - @speed * delta

    if newPos + (@width / 2) > (@world.middleOfLane 1) and @leftOfCentre()
      @x = newPos
    else if @rightOfCentre()
      @moveToCentre(delta)

  moveRight: (delta) ->
    newPos = @x + @speed * delta

    if newPos + (@width / 2) < (@world.middleOfLane 3) and @rightOfCentre()
      @x = newPos
    else if @leftOfCentre()
      @moveToCentre(delta)

  moveToCentre: (delta) ->
    distanceToMove = @returnSpeed * delta

    if Math.abs(@distanceFromCentre()) <= distanceToMove
      @centreOn (@world.middleOfLane 2)

    if @distanceFromCentre() > 200
      console.log "asdf"
    if @distanceFromCentre() > 0
      @x -= @returnSpeed * delta
    if @distanceFromCentre() < 0
      @x += @returnSpeed * delta

  distanceFromCentre: ->
    return @centre() - (@world.middleOfLane 2)

class SpriteImage
  ready: false

  constructor: (@world, url) ->
    image = new Image
    image.src = url
    image.onload = => @ready = true
    @image = image

  draw: (x, y) ->
    if @ready
      @world.ctx.drawImage(@image, x, y)
