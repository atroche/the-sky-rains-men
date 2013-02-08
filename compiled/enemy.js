// Generated by CoffeeScript 1.3.3
(function() {
  var Enemy,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Enemy = (function(_super) {

    __extends(Enemy, _super);

    Enemy.prototype.usedUpALife = false;

    function Enemy(world, lane) {
      this.world = world;
      this.lane = lane;
      this.lostLifeSound = this.world.assets.core.lostLife;
      Enemy.__super__.constructor.call(this, this.world);
    }

    Enemy.prototype.update = function(delta) {
      return Enemy.__super__.update.call(this, delta);
    };

    Enemy.prototype.onTouchingPlayer = function() {
      if (!this.usedUpALife) {
        this.world.lives -= 1;
        if (this.world.gameOver()) {
          this.world.dyingSound.play();
        }
        this.usedUpALife = true;
        this.lostLifeSound.play();
      }
      return Enemy.__super__.onTouchingPlayer.call(this);
    };

    Enemy.probability = function() {
      return 0.5;
    };

    return Enemy;

  })(FallingThing);

  window.Enemy = Enemy;

}).call(this);