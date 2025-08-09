require 'ruby2d'
require_relative 'grid'
require_relative 'game'

# GAME_WIDTH = 720
# GAME_HEIGHT = 720
GAME_WIDTH = 1440
GAME_HEIGHT = 810
BLOCK_SIZE = 20

set title: "ruby's game of life"
set width: GAME_WIDTH
set height: GAME_HEIGHT

Grid.new(GAME_WIDTH, GAME_HEIGHT, BLOCK_SIZE, '#111111')
game = GameOfLife.new(GAME_WIDTH, GAME_HEIGHT, BLOCK_SIZE)

# event handlers
on :key_down do |event|
	close if event.key == 'escape' 
end

on :mouse_down do |event|
	game.handle_mouse_down(event)
end

on :mouse_up do
	game.handle_mouse_up()
end

on :mouse_move do |event|
	game.handle_mouse_move(event)
end

update do
	next unless game.game_started && Window.frames % game.speed == 0
	game.update()
end

show