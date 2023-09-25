#!/bin/ruby

require 'ruby2d'

# Utility methods

def steps_count(x1, y1, x2, y2, speed, trashhold = 0)
  Integer((Math.sqrt(distance_squared(x1, y1, x2, y2)) - trashhold) / speed + 0.5)
end

def distance_squared(x1, y1, x2, y2)
  (x2 - x1)**2 + (y2 - y1)**2
end

def step_towards(x0, y0, x1, y1, speed)
  return [x1, y1] if distance_squared(x0, y0, x1, y1) <= speed**2

  dx = x1 - x0
  dy = y1 - y0
  angle = Math.atan2(dy, dx)
  [x0 + Math.cos(angle) * speed, y0 + Math.sin(angle) * speed].map(&:to_i)
end

def closest_human(x, y, humans, ash = nil)
  if ash
    humans.union([[100, ash[0], ash[1]]]).min_by { |h| distance_squared(x, y, h[1], h[2]) }
  else
    humans..min_by { |h| distance_squared(x, y, h[1], h[2]) }
  end
end

@fib = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]

# Ash AI 

class Ai
  def initialize(width, height, zombie_speed, ash_speed, ash_range)
    @width = width
    @height = height
    @zombie_speed = zombie_speed
    @ash_speed = ash_speed
    @ash_range = ash_range
  end

  def loop(ash, humans, zombies)
    priorities = []
    # human_multiplier = humans.length**2
    zombies.each do |z|
      target = closest_human(z[1], z[2], humans, ash)
      zombie_steps = steps_count(z[1], z[2], target[1], target[2], @zombie_speed)
      ash_steps = steps_count(ash[0], ash[1], z[3], z[4], @ash_speed, @ash_range)
      priorities.push([z, ash_steps + (target[0] == 100 ? 100 : 0)]) if ash_steps <= zombie_steps
    end
    ash_target = priorities.min_by { |p| p[1] }
    # p ash_target
    ash_target ? [ash_target[0][3], ash_target[0][4]] : ash
  end
end

width = 16_000
height = 9_000
@zombie_speed = 400
@ash_speed = 1000
@ash_range = 2000

factor = 10
screen_width = width / factor
screen_height = height / factor

set width: screen_width, height: screen_height

@ash = gets.split.map(&:to_i)
human_count = gets.to_i
@humans = []
human_count.times do
  human_id, human_x, human_y = gets.split.map(&:to_i)
  @humans.push([human_id, human_x, human_y])
end
zombie_count = gets.to_i
@zombies = []
# 0 - zombie_id, 1 - zombie_x, 2 - zombie_y, 5 - human_id or target
zombie_count.times do
  zombie_id, zombie_x, zombie_y, zombie_xnext, zombie_ynext = gets.split.map(&:to_i)
  @zombies.push([zombie_id, zombie_x, zombie_y, zombie_xnext, zombie_ynext, 100, -1])
end

@ai = Ai.new width, height, @zombie_speed, @ash_speed, @ash_range

def loop()
  ash_target = @ai.loop(@ash, @humans, @zombies)
  @ash = step_towards(@ash[0], @ash[1], ash_target[0], ash_target[1], @ash_speed)
  @zombies.map! do |zombie|
    zombie[1] = zombie[3]
    zombie[2] = zombie[4]
    zombie
  end
  @zombies.reject! { |z| distance_squared(@ash[0], @ash[1], z[1], z[2]) <= @ash_range**2 }
  if @zombies.empty?
    puts 'You won'
    return
  end

  @humans.reject! { |h| @zombies.any? { |z| h[1] == z[1] && h[2] == z[2] } }
  if @humans.empty?
    puts 'You lost'
    return
  end

  @zombies.map! do |zombie|
    target = closest_human(zombie[1], zombie[2], @humans, @ash)
    turns_to_target = steps_count(zombie[0], zombie[1], target[0], target[1], @zombie_speed)
    pos = step_towards(zombie[1], zombie[2], target[1], target[2], @zombie_speed)
    zombie[3] = pos[0]
    zombie[4] = pos[1]
    zombie[5] = target[0]
    zombie[6] = turns_to_target
    zombie
  end
  #p @humans
  #p @zombies
end

canvas = Canvas.new width: screen_width, height: screen_height

on :key_down do |event|
  if event.key == 'q'
    exit
  elsif event.key == 'l'
    loop
  end
end

update do
  canvas.clear
  canvas.fill_circle(x: @ash[0] / factor, y: @ash[1] / factor, radius: 3, sectors: 32, color: 'blue')
  canvas.draw_circle(x: @ash[0] / factor, y: @ash[1] / factor, radius: @ash_range / factor, sectors: 32, stroke_width: 1, color: 'blue')
  canvas.draw_circle(x: @ash[0] / factor, y: @ash[1] / factor, radius: @ash_speed / factor, sectors: 32, stroke_width: 1, color: 'blue')
  @humans.each do |human|
    canvas.fill_circle(x: human[1] / factor, y: human[2] / factor, radius: 3, sectors: 32, color: 'white')
  end
  @zombies.each do |zombie|
    zombie_x = zombie[1] / factor
    zombie_y = zombie[2] / factor
    canvas.fill_circle(x: zombie_x, y: zombie_y, radius: 3, sectors: 32, color: 'red')
    canvas.draw_circle(x: zombie_x, y: zombie_y, radius: @zombie_speed / factor, sectors: 32, stroke_width: 1, color: 'red')
    target = @humans[zombie[5]]
    canvas.draw_line(x1: zombie_x, y1: zombie_y, x2: target[1] / factor, y2: target[2] / factor, color: 'red') if target
    text = Text.new(zombie[6].to_s)
    text.draw x: zombie_x, y: zombie_y, color: 'red', rotate: 0
  end
  canvas.update
end

show
