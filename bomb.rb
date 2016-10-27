class Bomb
  attr_reader :x, :y, :power
  EXPLODE_TIME = 1500 #ms

  def initialize(x, y, power=3)
    @x, @y = x, y
    @sprite = Gosu::Image.new('bomb.png', :tileable => true)
    @timer = Gosu.milliseconds
    @power = power
  end

  def draw
    @sprite.draw(@x, @y, ZOrder::BOMB)
  end

  def update
    explode! if timer_expired?
  end

  def apply_explosion(map)
    self.power.times do |i|
      object = object_hit(map, @x + (i * Constants::TILE_SIZE), @y)
      break unless object == :ground
    end
    self.power.times do |i|
      object = object_hit(map, @x - (i * Constants::TILE_SIZE), @y)
      break unless object == :ground
    end
    self.power.times do |i|
      object = object_hit(map, @x, @y + (i * Constants::TILE_SIZE))
      break unless object == :ground
    end
    self.power.times do |i|
      object = object_hit(map, @x, @y - (i * Constants::TILE_SIZE))
      break unless object == :ground
    end
  end

  private

  def object_hit(map, x, y)
    players = $window.get_hit_player(x, y)
    players.each do |player|
      player.kill
    end
    return :player unless players.empty?
    if map.is_ground?(x, y)
      return :ground
    end
    if map.is_wall?(x, y)
      return :wall
    end
    if map.is_box?(x, y)
      map.destroy_box(x, y)
      return :box
    end

  end

  def timer_expired?
    @timer + EXPLODE_TIME < Gosu.milliseconds
  end

  def explode!
    $window.bomb_explode(self)
  end
end