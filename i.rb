require 'ruby2d'
require_relative 'grid'

GAME_WIDTH = 1440
GAME_HEIGHT = 810
BLOCK_SIZE = 20
$game_started = false
$active_squares = {}
$mouse_is_clicked = false
$drag_mode = nil # can be :add or :remove
$squares_to_add = []
$squares_to_remove = []

set title: "ruby's game of life"
set width: GAME_WIDTH
set height: GAME_HEIGHT

grid = Grid.new(GAME_WIDTH, GAME_HEIGHT, BLOCK_SIZE, '#111111')
grid.draw()

def add_square(x, y)
	key = "#{x},#{y}"
	square = Square.new(
		x: x, y: y,
		size: BLOCK_SIZE,
		color: '#00ff00',
		opacity: rand()
	)
	$active_squares[key] = square
	$alert_message.remove if $alert_message.respond_to?(:remove)
end

def remove_square(x, y)
	key = "#{x},#{y}"
	if $active_squares[key]
		$active_squares[key].remove
		$active_squares.delete(key)
	end
end

def toggle_square(x, y)
	key = "#{x},#{y}"
	if $active_squares[key]
		remove_square(x, y)
	else
		add_square(x, y)
	end
end

$button_container = Rectangle.new(
	x: 10,
	y: 10,
	width: 80,
	height: 30,
	color: '#ffffff',
	z: 1
)
$button_inner = Rectangle.new(
	x: 11,
	y: 11,
	width: 78,
	height: 28,
	color: '#444444',
	z: 1
)
$button_text = Text.new(
	'BEGIN',
	x: 17,
	y: 11,
	color: 'green',
	z: 1
)

$alert_message = Text.new(
	'DRAW SOME SQUARES FIRST!',
	x: GAME_WIDTH / 2 - 50 * 8,
	y: GAME_HEIGHT / 2 - 50,
	color: 'white',
	size: 50,
	show: false,
	z: 1
)

# This works because Ruby uses integer division when both
# operands are integers. When you divide an integer by another integer
# it automatically TRUNCATES (rounds down) to the nearest whole number.
# This is the rounding outcome we want, we just have to multiply 
# by BLOCK_SIZE then to get back to the nearest BLOCK_SIZE
def round_down_to_nearest_BLOCK_SIZE(n)
  (n / BLOCK_SIZE) * BLOCK_SIZE
end

def trigger_interaction
	if !$game_started
		if $active_squares.length == 0
			$alert_message.add
		else
			$alert_message.remove if $alert_message.respond_to?(:remove)
			$button_text.text = 'RESET'
			$game_started = true
		end
	else
		$button_text.text = 'BEGIN'
		$active_squares.each_value { |square| square.remove }
		$active_squares = {}
		$squares_to_add = []
		$squares_to_remove = []
		$game_started = false
	end
end

def count_neighbors(x, y)
	neighbor_keys = [
		"#{x + BLOCK_SIZE},#{y}",      					# right
		"#{x - BLOCK_SIZE},#{y}",      					# left
		"#{x},#{y - BLOCK_SIZE}",      					# top
		"#{x},#{y + BLOCK_SIZE}",      					# bottom
		"#{x + BLOCK_SIZE},#{y - BLOCK_SIZE}",	# top-right
		"#{x + BLOCK_SIZE},#{y + BLOCK_SIZE}",	# bottom-right
		"#{x - BLOCK_SIZE},#{y - BLOCK_SIZE}",	# top-left
		"#{x - BLOCK_SIZE},#{y + BLOCK_SIZE}" 	# bottom-left
	]

	neighbor_keys.count { |key| $active_squares[key] }
end

def get_all_potential_squares
	potential_squares = Set.new

	$active_squares.each_value do |square|
		# add the current alive square
		potential_squares.add([square.x, square.y])

		# add all neighbors (potential birth locations)
		# -BLOCK_SIZE previous, BLOCK_SIZE next (for x and y)
		[-BLOCK_SIZE, 0, BLOCK_SIZE].each do |dx|
			[-BLOCK_SIZE, 0, BLOCK_SIZE].each do |dy|
				next if dx == 0 && dy == 0
				potential_squares.add([square.x + dx, square.y + dy])
			end
		end
	end

	potential_squares #returns automatically (thanks Ruby!)
end

# event handlers
on :key_down do |event|
	close if event.key == 'escape' 
end

on :mouse_down do |event|
	if $button_container.contains? event.x, event.y
		trigger_interaction()
	elsif $game_started
		puts 'no clicky!'
	else
		$mouse_is_clicked = true
		x = round_down_to_nearest_BLOCK_SIZE(event.x)
		y = round_down_to_nearest_BLOCK_SIZE(event.y)

		# determine drag mode based on what's in the current position
		key = "#{x},#{y}"
		if $active_squares[key]
			$drag_mode = :remove
			remove_square(x, y)
		else
			$drag_mode = :add
			add_square(x, y)
		end
	end
end

on :mouse_up do
	$mouse_is_clicked = false
	$drag_mode = nil 
end

on :mouse_move do |event|
	if $mouse_is_clicked && !$game_started
		x = round_down_to_nearest_BLOCK_SIZE(event.x)
		y = round_down_to_nearest_BLOCK_SIZE(event.y)
		key = "#{x},#{y}"

		if $drag_mode == :add && !$active_squares[key]
			add_square(x, y)
		elsif $drag_mode == :remove && $active_squares[key]
			remove_square(x, y)
		end
	end
end


# animation loop
update do
	if $game_started && Window.frames % 10 == 0
		potential_squares = get_all_potential_squares

		potential_squares.each do |x, y|
			key = "#{x},#{y}"
			neighbor_count = count_neighbors(x, y)
			is_alive = $active_squares[key]

			if is_alive
				# square dies if it doesn't have 2 or 3 neighbors
				if neighbor_count != 2 && neighbor_count != 3
					$squares_to_remove << [x, y]
				end
			else
				# dead squares spring to life if they have 3 neighbors
				if neighbor_count == 3
					$squares_to_add << [x, y]
				end
			end
		end

		# apply changes after evaluation
		$squares_to_remove.each { |x, y| remove_square(x, y) }
		$squares_to_add.each { |x, y| add_square(x, y)}

		# Clear arrays for next generation
		$squares_to_add = []
		$squares_to_remove = []
	end
end

show