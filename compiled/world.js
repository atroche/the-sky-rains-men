// Generated by CoffeeScript 1.3.3
(function() {
  var World, shuffle,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  shuffle = function(o) {
    var i, j, x;
    j = void 0;
    x = void 0;
    i = o.length;
    while (i) {
      j = parseInt(Math.random() * i);
      x = o[--i];
      o[i] = o[j];
      o[j] = x;
    }
    return o;
  };

  World = (function() {

    World.height = 1000;

    World.prototype.height = 1000;

    World.prototype.width = 370;

    World.prototype.laneLineWidth = 10;

    World.prototype.leftBoundary = 0;

    World.prototype.rightBoundary = 500;

    World.prototype.numLanes = 3;

    World.prototype.lives = 3;

    World.prototype.showHitBoxes = false;

    World.prototype.score = 0;

    function World(assets) {
      this.assets = assets;
      this.middleOfLane = __bind(this.middleOfLane, this);

      this.setupCanvasContext();
      this.initialSpeed = 350;
      this.acceleration = 1;
      this.elapsedTime = 0;
      this.enemyTypes = [Goblin, Skeleton, Bat, Wizard, ExtraLife];
      this.laneWidth = this.width / this.numLanes;
      this.enemiesSinceLastTreasure = 0;
      this.player = new Player(this);
      this.objects = [this.player];
      this.dyingSound = this.assets.core.dying;
      this.enemyQueue = this.queueMonsters();
    }

    World.prototype.setupCanvasContext = function() {
      this.canvas = document.getElementById('game');
      this.canvas.width = 800;
      this.canvas.height = 600;
      this.ctx = this.canvas.getContext('2d');
      this.ctx.webkitImageSmoothingEnabled = false;
      return this.ctx.font = "bold 16pt Arial";
    };

    World.prototype.feasibleEnemiesToDrop = function(hitTime) {
      return this.enemyTypes.filter(function(enemy) {
        return hitTime > enemy.timeToHit() && hitTime > enemy.releaseTime();
      });
    };

    World.prototype.queueMonsters = function() {
      var chooseEnemy, dropQueue, feasibleEnemies, hitInfo, hitInfoToDropInfo, hitTime, newEnemy, newHitTime, newLane, oldLane, queue, reactionTime;
      queue = [];
      hitTime = 0;
      oldLane = 2;
      while (hitTime < 1000 * 60 * 5) {
        feasibleEnemies = shuffle(this.feasibleEnemiesToDrop(hitTime));
        chooseEnemy = function() {
          var enemyType, _i, _len;
          for (_i = 0, _len = feasibleEnemies.length; _i < _len; _i++) {
            enemyType = feasibleEnemies[_i];
            if (enemyType.probability() > Math.random()) {
              return enemyType;
            }
          }
        };
        if (feasibleEnemies.length === 0) {
          hitTime += 1;
          continue;
        }
        if (this.enemiesSinceLastTreasure > 4) {
          newEnemy = Treasure;
          this.enemiesSinceLastTreasure = 0;
        } else {
          newEnemy = null;
          while (!newEnemy) {
            newEnemy = chooseEnemy();
          }
          this.enemiesSinceLastTreasure += 1;
        }
        newLane = Math.floor(Math.random() * this.numLanes) + 1;
        if (queue.length === 0) {
          reactionTime = this.initialSpeed;
        } else {
          reactionTime = this.initialSpeed + 50 - (hitTime * (1 / (this.acceleration * 1000)));
        }
        newHitTime = hitTime + this.timeBetweenLanes(oldLane, newLane) + reactionTime;
        queue.push([newEnemy, newHitTime, newLane]);
        hitTime = newHitTime;
        oldLane = newLane;
      }
      hitInfoToDropInfo = function(hitInfo) {
        var enemyType, hitAt, lane;
        enemyType = hitInfo[0];
        hitAt = hitInfo[1];
        lane = hitInfo[2];
        return [enemyType, hitAt - enemyType.timeToHit(), lane];
      };
      dropQueue = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = queue.length; _i < _len; _i++) {
          hitInfo = queue[_i];
          _results.push(hitInfoToDropInfo(hitInfo));
        }
        return _results;
      })();
      return dropQueue;
    };

    World.prototype.timeBetweenLanes = function(prevLane, newLane) {
      var timeToMiddleLane, timeToSideLane;
      timeToSideLane = this.laneWidth / this.player.speed;
      timeToMiddleLane = this.laneWidth / this.player.returnSpeed;
      if (prevLane === 2) {
        return timeToSideLane;
      } else if (newLane === 2) {
        return timeToMiddleLane;
      } else {
        return timeToMiddleLane + timeToSideLane;
      }
    };

    World.prototype.aliveObjects = function() {
      var object;
      return (function() {
        var _i, _len, _ref, _results;
        _ref = this.objects;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          if (object.dead !== true) {
            _results.push(object);
          }
        }
        return _results;
      }).call(this);
    };

    World.prototype.reset = function() {
      this.enemyQueue = this.queueMonsters();
      this.elapsedTime = 0;
      this.player = new Player(this);
      this.objects = [this.player];
      this.lives = 3;
      return this.score = 0;
    };

    World.prototype.update = function(delta) {
      var drop, dropInfo, object, sendEnemy, toDrop, _i, _j, _len, _len1, _ref, _results,
        _this = this;
      if (this.gameOver()) {
        return;
      }
      this.elapsedTime += delta;
      toDrop = (function() {
        var _i, _len, _ref, _results;
        _ref = this.enemyQueue;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dropInfo = _ref[_i];
          if (this.elapsedTime >= dropInfo[1] - (dropInfo[0].stopFor || 0)) {
            _results.push([dropInfo[0], dropInfo[2]]);
          }
        }
        return _results;
      }).call(this);
      this.enemyQueue = (function() {
        var _i, _len, _ref, _results;
        _ref = this.enemyQueue;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dropInfo = _ref[_i];
          if (this.elapsedTime < dropInfo[1] - (dropInfo[0].stopFor || 0)) {
            _results.push(dropInfo);
          }
        }
        return _results;
      }).call(this);
      sendEnemy = function(enemyType, lane) {
        return _this.objects.push(new enemyType(_this, lane));
      };
      for (_i = 0, _len = toDrop.length; _i < _len; _i++) {
        drop = toDrop[_i];
        sendEnemy(drop[0], drop[1]);
      }
      _ref = this.aliveObjects();
      _results = [];
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        object = _ref[_j];
        _results.push(object.update(delta));
      }
      return _results;
    };

    World.prototype.render = function() {
      var object, _i, _len, _ref, _results;
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.drawLives();
      this.drawTimer();
      if (this.gameOver()) {
        return this.promptReplay();
      } else {
        _ref = this.aliveObjects();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          _results.push(object.render());
        }
        return _results;
      }
    };

    World.prototype.gameOver = function() {
      return this.lives <= 0;
    };

    World.prototype.promptReplay = function() {
      return this.ctx.fillText("Press any key to play again", this.width + 50, 120);
    };

    World.prototype.drawLanes = function() {
      var laneHeight, laneX, _results;
      laneHeight = this.height - 50;
      laneX = 0;
      _results = [];
      while (laneX <= this.width) {
        this.ctx.fillStyle = "white";
        this.ctx.fillRect(laneX, 10, this.laneLineWidth, laneHeight);
        _results.push(laneX += this.laneWidth);
      }
      return _results;
    };

    World.prototype.middleOfLane = function(laneNum) {
      return this.laneLineWidth / 2 + (laneNum - 1) * this.laneWidth + this.laneWidth / 2;
    };

    World.prototype.drawLives = function() {
      this.ctx.fillStyle = "white";
      return this.ctx.fillText(this.lives, this.width + 50, 60);
    };

    World.prototype.drawTimer = function() {
      this.ctx.fillStyle = "white";
      return this.ctx.fillText("Score: " + this.score, this.width + 50, 90);
    };

    World.prototype.setAcceleration = function(acceleration) {
      return this.acceleration = acceleration;
    };

    World.prototype.setInitialSpeed = function(initialSpeed) {
      return this.initialSpeed = initialSpeed;
    };

    World.prototype.setPlayerSpeed = function(playerSpeed) {
      return this.player.speed = playerSpeed;
    };

    return World;

  })();

  window.World = World;

}).call(this);
