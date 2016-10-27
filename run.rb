require 'gosu'

Dir["./*.rb"].each {|file| require file }

class GameWindow < Gosu::Window
  def initialize(height, width)
    super(height, width)
    self.caption = 'bomberman'
    $window = self
    @font = Gosu::Font.new($window, Gosu.default_font_name, 20)
    @map = Map.new(height / Constants::TILE_SIZE, width / Constants::TILE_SIZE)
    @players = [Player.new(0), Player.new(1, height - 3 * Constants::TILE_SIZE, width - 3 * Constants::TILE_SIZE)]
  end

  def update
    @players.each {|player| self.close if player.killed?}
    @players.each do |player|
      player.update(player.get_direction, @map)
    end
    self.close if button_down? Constants::PREV
    @map.update
  end

  def button_up(id)
    add_bomb(0) if Constants::BOMB_PLAYER_0 == id
    add_bomb(1) if Constants::BOMB_PLAYER_1 == id
  end

  def draw
    write("#{Gosu.fps} FPS", 1, 1)
    @map.draw
    @players.each {|player| player.draw}
  end

  def bomb_explode(bomb)
    @map.destroy_bomb(bomb)
  end

  def get_hit_player(x, y)
    hit_players = []
    @players.each do |player|
      hit_players << player if player.is_in?(x, y)
    end
    hit_players
  end

  private

  def add_bomb(player_nb)
    pos = @players[player_nb].get_foot_pos
    x, y = *pos
    @map.add_bomb(Bomb.new(x, y))
  end

  def write(str, x, y)
    @font.draw(str, x, y, ZOrder::FONT, 1.0, 1.0, Gosu::Color::RED)
  end
end

window = GameWindow.new(640, 480)
window.show