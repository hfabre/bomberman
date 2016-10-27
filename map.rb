class Map
  attr_reader :height, :width, :map

  def initialize(width, height)
    @height = height
    @width = width
    @map = generate
    @textures = [
      Gosu::Image.new('ground.png', :tileable => true),
      Gosu::Image.new('wall.png', :tileable => true),
      Gosu::Image.new('box.png', :tileable => true),
      Gosu::Image.new('bomb.png', :tileable => true)
    ]
    @bombs = []
  end

  def self.board
    @map
  end

  def show
    @map.each {|line| line.each {|c| print c}; print "\n"}
  end

  def draw
    @map.each_with_index {|line, j| line.each_with_index {|c, i| @textures[c].draw(i * Constants::TILE_SIZE, j * Constants::TILE_SIZE, ZOrder::MAP)}}
    @bombs.each {|bomb| bomb.draw}
  end

  def update
    @bombs.each {|bomb| bomb.update}
  end

  def is_ground?(x, y)
    @map[y / Constants::TILE_SIZE][x / Constants::TILE_SIZE] == Constants::GROUND
  end

  def is_box?(x, y)
    @map[y / Constants::TILE_SIZE][x / Constants::TILE_SIZE] == Constants::BOX
  end

  def is_wall?(x, y)
    @map[y / Constants::TILE_SIZE][x / Constants::TILE_SIZE] == Constants::WALL
  end

  def destroy_box(x, y)
    @map[y / Constants::TILE_SIZE][x / Constants::TILE_SIZE] = Constants::GROUND
  end

  def add_bomb(bomb)
    @bombs << bomb
  end

  def destroy_bomb(bomb)
    @bombs.delete(bomb)
    bomb.apply_explosion(self)
    bomb = nil
  end

  private

  def generate
    map = []
    map << generate_border
    (@height - 2).times do
      map << generate_line
    end
    map << generate_border
    map[1][1] = Constants::GROUND
    map[2][1] = Constants::GROUND
    map[1][2] = Constants::GROUND
    map[height - 2][width - 2] = Constants::GROUND
    map[height - 3][width - 2] = Constants::GROUND
    map[height - 2][width - 3] = Constants::GROUND
    map[height - 3][width - 3] = Constants::GROUND
    map
  end

  def generate_border
    border = []
    @width.times do
      border << Constants::WALL
    end
    border
  end

  def generate_line
    ground_percent = Array.new(5, Constants::GROUND)
    wall_parcent = Array.new(1, Constants::WALL)
    box_percent = Array.new(4, Constants::BOX)
    generation = ground_percent + wall_parcent + box_percent
    line = []
    @width.times do
      line << generation.sample
    end
    line[0] = Constants::WALL
    line[@width-1] = Constants::WALL
    line
  end
end