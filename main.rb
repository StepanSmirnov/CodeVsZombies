#!/bin/ruby

require 'ruby2d'

class Ai
  def initialize(width, height, zombie_speed, ash_speed, ash_range)
    @width = width
    @height = height
    @zombie_speed = zombie_speed
    @ash_speed = ash_speed
    @ash_range = ash_range
  end

  def loop(ash, humans, zombies)
    [0, 0]
  end
end

width = 16_000
height = 9_000
zombie_speed = 400
ash_speed = 1000
range = 2000

factor = 10
screen_width = width / factor
screen_height = height / factor

# set width: screen_width, height: screen_height
# canvas = Canvas.new width: screen_width, height: screen_height
#
# canvas.draw_circle(x: 800, y: 800, radius: 50, sectors: 32, stroke_width: 1, color: 'red')
# show
ash_x, ash_y = gets.split.map(&:to_i)
human_count = gets.to_i
humans = []
human_count.times do
  human_id, human_x, human_y = gets.split.map(&:to_i)
  humans.push([human_id, human_x, human_y])
end
zombie_count = gets.to_i
zombies = []
# 0 - zombie_id, 1 - zombie_x, 2 - zombie_y, 5 - human_id or target
zombie_count.times do
  zombie_id, zombie_x, zombie_y, zombie_xnext, zombie_ynext = gets.split.map(&:to_i)
  zombies.push([zombie_id, zombie_x, zombie_y, zombie_xnext, zombie_ynext, -1])
end

while true
  break
end
