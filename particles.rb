begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end

require 'gosu'
include Gosu

# Our window size
module Dimensions
  Width, Height = 1280, 720
end

# Our layers for drawing.
module ZOrder
  Background, Shadow, Shape, Highlight = *0..3
end

# One particle is basically a sprite, that moves itself by speed every tick along an angle.
# It also has a concept of decay, in how quickly the particle dies. In this case, the draw
# command takes into account decay to shrink the particles and make them more translucent.
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
    @angle += (@speed / 2)
  end
  
  def dead?
    @life <= 0
  end
  
  def draw_layer(layer, color, x = nil, y = nil)
    @sprite.draw_rot(x || @x, y || @y, layer, @angle, 0.5, 0.5, @life, @life, color, :default)    
  end
  
  def draw
    return if dead?
    draw_layer(ZOrder::Shadow, Gosu::Color.new((@life * 128).floor,0,0,0), @x+2, @y+2)
    draw_layer(ZOrder::Shape, Gosu::Color.new((@life * 255).floor, 255,255,0))
    draw_layer(ZOrder::Highlight, Gosu::Color.new((@life * 20).floor,255,255,255))
  end
end

# This class keeps track of our moving particles. It loads in a few white png files, and removes
# dead particles during every tick. They could probably be garbage collected less frequently.
class Particles
  
  SPRITES = ['leaf', 'leaf2', 'leaf3', 'star', 'fuzzy']
  def initialize(window)
    @particles = []
    @sprites = Particles::SPRITES.collect {|s| Gosu::Image.new(window, "images/#{s}.png", true)}
  end
  
  def update
    @particles.each {|p| p.update}
    @particles.delete_if {|p| p.dead?}
  end
  
  def draw
    @particles.each {|p| p.draw}
  end
  
  def create(x, y, angle, speed)
    @particles << Particle.new(@sprites[(rand * @sprites.size).floor], x, y, angle, speed, 0.01)
  end
  
end

# An emitter simply emits particles at a regular interval. In this case, every
# time spawn is called, a new particle is generated with a random angle of movement and speed.
class Emitter  
  def initialize(particles, x, y)
    @particles = particles
    @x = x
    @y = y
  end
  
  def spawn
    @particles.create(@x, @y, rand * 360, (rand * 3)+3)
  end
end

class GameWindow < Gosu::Window
  def initialize
    super(Dimensions::Width, Dimensions::Height, false)
    self.caption = "Particle Effects"
    
    @background_image = Gosu::Image.new(self, "images/background.png", true)
    @particles = Particles.new(self)
    @emitter = Emitter.new(@particles, Dimensions::Width / 2, Dimensions::Height / 2)
  end

  # Called every tick by gosu to update object positions
  def update
    @emitter.spawn
    @particles.update
  end

  # Called every tick by gosu to draw things on the screen
  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @particles.draw
  end
  
  # Quit on ESC
  def button_down(id)
    close if id == Gosu::Button::KbEscape
  end
end

# Create the gosu window
window = GameWindow.new
window.show