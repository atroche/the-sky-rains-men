$(->
  game = new Game
  game.run()
)




class Game

  FPS: 60

  constructor: ->
    @lastUpdate = Date.now()

    @keysDown = {}

    $("body").keydown (e) =>
      @keysDown[e.keyCode] = true
      if e.keyCode in [37, 39]
        e.preventDefault()
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

  reactToInput: ->
    if 37 of @keysDown
      lane = 1 # left
    else if 39 of @keysDown
      lane = 3 # right
    else
      lane = 2 # middle

    @world.player.moveToLane lane

  update: (delta) ->
    @reactToInput()
    @world.update(delta)

  render: ->
    @world.render()

  run: ->
    setInterval(@main, 1000 / @FPS)







class World

  height: 500
  width: 500
  laneLineWidth: 10
  numLanes: 3

  constructor: ->
    @laneWidth = (@width / @numLanes)

    @timeSinceLastThingFell = 2000

    @canvas = document.getElementById('game')
    @canvas.width = @canvas.parentNode.clientWidth
    @canvas.height = @canvas.parentNode.clientHeight

    @ctx = @canvas.getContext('2d')
    @ctx.webkitImageSmoothingEnabled = false

    @score = 0

    @player = new Player(this)

    @objects = [@player]

  aliveObjects: ->
    return (object for object in @objects when object.dead isnt true)

  update: (delta) ->
    @timeSinceLastThingFell += delta

    if @timeSinceLastThingFell >= 1000
      @objects.push (new FallingThing(this))
      @timeSinceLastThingFell = 0

    object.update(delta) for object in @aliveObjects()

  render: ->
    # clear canvas for redrawing!
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)

    @drawLanes()
    @drawScore()

    object.render() for object in @aliveObjects()

  drawLanes: ->

    laneX = 0
    while laneX <= @width
      @ctx.fillStyle = "black"
      @ctx.fillRect(laneX, 10, @laneLineWidth, @height)
      laneX += @laneWidth

  middleOfLane: (laneNum) =>
    return @laneLineWidth / 2 + (laneNum - 1) * @laneWidth + @laneWidth / 2

  drawScore: ->
    @ctx.font = "bold 16pt Arial"
    @ctx.fillText(@score, @width + 50, 30)

class FallingThing

  y: 10

  constructor: (@world, @lane) ->
    @height = 10
    @width = @world.width / 18

    # a la Python's random.choice
    @lane = Math.floor(Math.random() * @world.numLanes) + 1

    @centreOn (@world.middleOfLane @lane)

  render: ->
    unless @dead
      @world.ctx.fillStyle = "red"
      @world.ctx.fillRect(@x, @y, @width, @height)

  update: (delta) ->
    @y += delta * 0.15

    pastPlayer = @y > @world.player.y and @y < @world.player.y + 20
    inSameLaneAsPlayer = @lane == @world.player.lane

    if pastPlayer and inSameLaneAsPlayer
      @destroy()
      @world.score += 1

  destroy: ->
    @dead = true

  centreOn: (centreX) ->
    @x = centreX - (@width / 2)


class Player

  constructor: (@world) ->
    @lane = 2
    @y = @world.height

    @width = @world.width / 12
    @height = 10

    @sprite = new SpriteImage(@world, "nyancat.png")

  render: ->
    @sprite.draw(@x, @y)

  update: (delta) ->
    @centreOn (@world.middleOfLane @lane)

  moveToLane: (lane) ->
    @lane = lane

  centreOn: (centreX) ->
    @x = centreX - (@width / 2)


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
