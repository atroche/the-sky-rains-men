class World

  height: 500
  width: 500
  laneLineWidth: 10
  leftBoundary: 0
  rightBoundary: 500
  numLanes: 3
  lives: 3
  showHitBoxes: false

  constructor: ->
    @elapsedTime = 0

    @fallingTypes = [Goblin, Skeleton, ExtraLife]

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

    nextThing = @fallingTypes[Math.floor(Math.random() * @fallingTypes.length)]

    if @timeSinceLastThingFell >= 600
      @objects.push (new nextThing(this))
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

window.World = World