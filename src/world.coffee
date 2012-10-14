class World

  @height: 500
  height: 500
  width: 500
  laneLineWidth: 10
  leftBoundary: 0
  rightBoundary: 500
  numLanes: 3
  lives: 3
  showHitBoxes: false
  pickupRate: 10

  constructor: (@assets) ->
    @elapsedTime = 0

    @enemyTypes = [Goblin, Skeleton, Bat, Wizard]
    @pickupTypes = [ExtraLife]

    @laneWidth = (@width / @numLanes)

    @timeSinceLastThingFell = 2000
    @thingsSincePickup = 0

    @canvas = document.getElementById('game')
    @canvas.width = 800
    @canvas.height = 600

    @ctx = @canvas.getContext('2d')
    @ctx.webkitImageSmoothingEnabled = false
    @ctx.font = "bold 16pt Arial"

    @player = new Player(this)

    @objects = [@player]

    @dyingSound = @assets.core.dying

    @enemyQueue = @queueMonsters()

  queueMonsters: ->
    queue = []
    choice = (array) -> array[Math.floor(Math.random() * array.length)]
    hitTime = 0
    oldLane = 2
    while hitTime < 1000 * 60 * 3
      feasibleEnemies = @enemyTypes.filter (enemy) ->
        hitTime > enemy.timeToHit() and hitTime > enemy.releaseTime()

      if feasibleEnemies.length == 0
        hitTime += 1
        continue
      newEnemy = choice(feasibleEnemies)
      newLane = Math.floor(Math.random() * @numLanes) + 1

      if queue.length == 0
        reactionTime = 0
      else if hitTime > 25 * 1000
        reactionTime = 190
      else if hitTime > 20 * 1000
        reactionTime = 210
      else if hitTime > 10 * 1000
        reactionTime = 220
      else if hitTime > 5 * 1000
        reactionTime = 230
      else
        reactionTime = 240

      newHitTime = hitTime + @timeBetweenLanes(oldLane, newLane) + reactionTime
      queue.push([newEnemy, newHitTime, newLane])

      hitTime = newHitTime
      oldLane = newLane

    hitInfoToDropInfo = (hitInfo) ->
      enemyType = hitInfo[0]
      hitAt = hitInfo[1]
      lane = hitInfo[2]

      return [enemyType, hitAt - enemyType.timeToHit(), lane]

    dropQueue = (hitInfoToDropInfo(hitInfo) for hitInfo in queue)
    return dropQueue


  timeBetweenLanes: (prevLane, newLane) ->
    timeToSideLane = @laneWidth / @player.speed
    timeToMiddleLane = @laneWidth / @player.returnSpeed

    if prevLane == 2
      return timeToSideLane
    else if newLane == 2
      return timeToMiddleLane
    else
      return timeToMiddleLane + timeToSideLane

  aliveObjects: ->
    return (object for object in @objects when object.dead isnt true)

  reset: ->
    @enemyQueue = @queueMonsters()
    @elapsedTime = 0

    @player = new Player(this)
    @objects = [@player]

    @lives = 3

  update: (delta) ->
    if @gameOver()
      return

    @elapsedTime += delta

    toDrop = ([dropInfo[0], dropInfo[2]] for dropInfo in @enemyQueue when @elapsedTime >= dropInfo[1])
    @enemyQueue = (dropInfo for dropInfo in @enemyQueue when @elapsedTime < dropInfo[1])

    sendEnemy = (enemyType, lane) =>
      @objects.push (new enemyType(this, lane))

    sendEnemy(drop[0], drop[1]) for drop in toDrop

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