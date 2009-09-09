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
  def initialize(sprite, x, y, ang, speed)
    @x = x
    @y = y
    @d_x = offset_x(ang, speed)
    @d_y = offset_y(ang, speed)
    @angle = ang
    @life = 1
    @sprite = sprite
  end
  
  def update
    @x = @x + @d_x
    @y = @y + @d_y
    @life = @life - 0.01
    @angle += 1
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
    @particles << Particle.new(@fuzzy, x, y, angle, speed)
  end
  
end

class Emitter
  
  def initialize(particles)
    @particles = particles
  end
  
  def spawn
    @particles.create(Dimensions::Width / 2, Dimensions::Height / 3, (rand * 360), (rand * 5))
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
    @emitter = Emitter.new(@particles)
    
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