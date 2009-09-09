begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end

require 'gosu'
include Gosu

module Dimensions
  Width, Height = 1280, 720
end

module ZOrder
  Background, Fuzzy = *0..1
end

class Particle 
  def initialize(sprite, x, y, ang, speed, decay)
    @x = x
    @y = y
    @angle =  90-ang
    @speed = speed
    @d_x = offset_x(@angle, @speed)
    @d_y = offset_y(@angle, @speed)
    @life = 1
    @sprite = sprite
    @decay = decay
  end
  
  def update
    @x = @x + @d_x
    @y = @y + @d_y
    @life = @life - @decay
    @angle += (@speed / 3)
  end
  
  def color
    
  end
  
  def dead?
    @life <= 0
  end
  
  def draw
     @sprite.draw_rot(@x, 
                  @y, 
                  ZOrder::Fuzzy,
                  @angle,
                  0.5,
                  0.5,
                  @life, 
                  @life, 
                  Gosu::Color.new((@life * 255).floor, 255, 255, 255), 
                  :default)
  end
end

class Particles
  
  def initialize(window)
    @particles = []
    @fuzzy = Gosu::Image.new(window, "images/leaf.png", true)
  end
  
  def update
    to_remove = []
    @particles.each do |p| 
      p.update
      to_remove << p if p.dead?
    end
    
    to_remove.each {|r| @particles.delete(r)}
  end
  
  def draw
    @particles.each {|p| p.draw}
  end
  
  def create(x, y, angle, speed)
    @particles << Particle.new(@fuzzy, x, y, angle, speed, 0.002)
  end
  
end

class Emitter
  
  def initialize(particles, x, y)
    @particles = particles
    @x = x
    @y = y
  end
  
  def spawn
    @particles.create(@x, rand * Dimensions::Height, (rand * 30) + 165, (rand * 10))
  end
  def update(milliseconds)
    spawn if (rand < 0.1) 
  end
end



class GameWindow < Gosu::Window
  def initialize
    super(Dimensions::Width, Dimensions::Height, false)
    self.caption = "Gosu Tutorial Game"
    
    @background_image = Gosu::Image.new(self, "images/background.png", true)
    @particles = Particles.new(self)
    @emitter = Emitter.new(@particles, 1400, 400)
    
  end

  def update
    @emitter.update(milliseconds)
    @particles.update
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @particles.draw
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
end

window = GameWindow.new
window.show