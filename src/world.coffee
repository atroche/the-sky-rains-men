shuffle = (o) -> #v1.0
  j = undefined
  x = undefined
  i = o.length

  while i
    j = parseInt(Math.random() * i)
    x = o[--i]
    o[i] = o[j]
    o[j] = x
  o

class World

  @height: 1000
  height: 1000
  width: 370
  laneLineWidth: 10
  leftBoundary: 0
  rightBoundary: 500
  numLanes: 3
  lives: 3
  showHitBoxes: false
  score: 0

  constructor: (@assets) ->
    @setupCanvasContext()

    @initialSpeed = 350
    @acceleration = 1

    @elapsedTime = 0

    @enemyTypes = [Goblin, Skeleton, Bat, Wizard, ExtraLife]

    @laneWidth = (@width / @numLanes)

    @enemiesSinceLastTreasure = 0

    @player = new Player(this)

    @objects = [@player]

    @dyingSound = @assets.core.dying

    @enemyQueue = @queueMonsters()

  setupCanvasContext: ->
    @canvas = document.getElementById('game')
    @canvas.width = 800
    @canvas.height = 600


    @ctx = @canvas.getContext('2d')
    @ctx.webkitImageSmoothingEnabled = false
    @ctx.font = "bold 16pt Arial"

  feasibleEnemiesToDrop: (hitTime) ->
    return @enemyTypes.filter (enemy) ->
        hitTime > enemy.timeToHit() and hitTime > enemy.releaseTime()

  queueMonsters: ->
    queue = []
    hitTime = 0
    oldLane = 2
    while hitTime < 1000 * 60 * 5
      feasibleEnemies = shuffle(@feasibleEnemiesToDrop(hitTime))

      chooseEnemy = ->
        for enemyType in feasibleEnemies
          if enemyType.probability() > Math.random()
            return enemyType

      if feasibleEnemies.length == 0
        hitTime += 1
        continue

      if @enemiesSinceLastTreasure > 4
        newEnemy = Treasure
        @enemiesSinceLastTreasure = 0
      else
        newEnemy = null
        until newEnemy
          newEnemy = chooseEnemy()
        @enemiesSinceLastTreasure += 1

      newLane = Math.floor(Math.random() * @numLanes) + 1

      if queue.length == 0 # don't start with a delay!
        reactionTime = @initialSpeed
      else
        reactionTime = @initialSpeed + 50 - (hitTime * (1 / (@acceleration * 1000)))

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
    @score = 0

  update: (delta) ->
    if @gameOver()
      return

    @elapsedTime += delta

    toDrop = ([dropInfo[0], dropInfo[2]] for dropInfo in @enemyQueue when @elapsedTime >= dropInfo[1] - (dropInfo[0].stopFor or 0))
    @enemyQueue = (dropInfo for dropInfo in @enemyQueue when @elapsedTime < dropInfo[1]  - (dropInfo[0].stopFor or 0))

    sendEnemy = (enemyType, lane) =>
      @objects.push (new enemyType(this, lane))

    sendEnemy(drop[0], drop[1]) for drop in toDrop

    object.update(delta) for object in @aliveObjects()

  render: ->
    # clear canvas for redrawing!
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)



    # @drawLanes()
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
    @ctx.fillStyle = "white"
    @ctx.fillText(@lives, @width + 50, 60)

  drawTimer: ->
    @ctx.fillStyle = "white"

    @ctx.fillText("Score: " + @score, @width + 50, 90)

  setAcceleration: (acceleration) ->
    @acceleration = acceleration

  setInitialSpeed: (initialSpeed) ->
    @initialSpeed = initialSpeed

  setPlayerSpeed: (playerSpeed) ->
    @player.speed = playerSpeed

window.World = World