  class Player
  SPRITE_SIZE = 16
  FRAME_DELAY = 60 # ms
  ANIMATION_NB = 4
  SPEED = 2
  ADJUSTED_SPRITE_SIZE = SPRITE_SIZE - 1

  def initialize(id, x=0, y=0)
    @id = id
    @killed = false
    @sprite = load_sprite_from_image
    @facing = :down
    @image_count = 0
    @x, @y = Constants::TILE_SIZE + x, Constants::TILE_SIZE + y
  end

  def number
    @id
  end

  def update(direction, map)
    $key_pressed = direction
    unless direction.empty?
      @facing = direction
      if frame_expired?
        @image_count += 1
        @image_count = 0 if done?
      end
      move(direction, map)
    end
  end

  def get_direction
    direction = ''
    direction = :left if $window.button_down? Constants.const_get("LEFT_#{@id.to_s}")
    direction = :right if $window.button_down? Constants.const_get("RIGHT_#{@id.to_s}")
    direction = :up if $window.button_down? Constants.const_get("UP_#{@id.to_s}")
    direction = :down if $window.button_down? Constants.const_get("DOWN_#{@id.to_s}")
    direction
  end

  def draw
    return if done?
    @sprite[@facing][$key_pressed ? @image_count : 0].draw(@x, @y, ZOrder::PLAYER, 1, 1)
  end

  def done?
    @image_count == ANIMATION_NB
  end

  def hit_box(x=nil, y=nil)
    if !x && !y
      [[@x, @y], [@x + ADJUSTED_SPRITE_SIZE, @y], [@x, @y + ADJUSTED_SPRITE_SIZE], [@x + ADJUSTED_SPRITE_SIZE, @y + ADJUSTED_SPRITE_SIZE]]
    else
      [[x, y], [x + ADJUSTED_SPRITE_SIZE, y], [x, y + ADJUSTED_SPRITE_SIZE], [x + ADJUSTED_SPRITE_SIZE, y + ADJUSTED_SPRITE_SIZE]]
    end
  end

  def get_foot_pos
    [@x + 5, @y + 7]
  end

  def is_in?(x, y)
    true if x >= @x && x <= @x + ADJUSTED_SPRITE_SIZE && y >= @y && y <= @y + ADJUSTED_SPRITE_SIZE
  end

  def kill
    @killed = true
    p "Player #{@id} is dead"
  end

  def killed?
    @killed
  end

  private

  def will_collide?(x, y, map)
    pos_free = []
    hit_box(x, y).each do |pos|
      pos_free << map.is_ground?(pos.first, pos.last)
    end
    collide = pos_free.delete_if {|pos| pos}
    collide.size > 0
  end

  def move(direction, map)
    case direction
      when :up
        @y -= SPEED unless will_collide?(@x, @y - SPEED, map)
      when :down
        @y += SPEED unless will_collide?(@x, @y + SPEED, map)
      when :right
        @x += SPEED unless will_collide?(@x + SPEED, @y, map)
      when :left
        @x -= SPEED unless will_collide?(@x - SPEED, @y, map)
    end
  end

  def current_frame
    @sprite[@facing][@image_count % ANIMATION_NB]
  end

  def frame_expired?
   now = Gosu.milliseconds
   @last_frame ||= now
   if (now - @last_frame) > FRAME_DELAY
     @last_frame = now
   end
  end

  def load_sprite_from_image
    sprites = Gosu::Image.load_tiles($window, './sprite.png', SPRITE_SIZE, SPRITE_SIZE, false)
    {:left => sprites[4..7], :right => sprites[12..15],
      :down => sprites[0..3], :up => sprites[8..11]}
  end
end
