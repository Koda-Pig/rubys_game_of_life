require 'ruby2d'

GAME_WIDTH = 600
GAME_HEIGHT = 400
$game_started = false
$active_squares = {}
$mouse_is_clicked = false

set title: "ruby's game of life"
set width: GAME_WIDTH
set height: GAME_HEIGHT
set fps: 1

# Draw horizontal lines
(0...GAME_HEIGHT).each do |i|
	if i % 10 == 0
		Line.new(
			x1: 0, y1: i,
			x2: GAME_WIDTH, y2: i,
			width: 1,
			color: '#333333'
		)
	end
end

# Draw vertical lines
(0...GAME_WIDTH).each do |i|
	if i % 10 == 0
		Line.new(
			x1: i, y1: 0,
			x2: i, y2: GAME_WIDTH,
			width: 1,
			color: '#333333'
		)
	end
end

def add_square(x, y)
	key = "#{x},#{y}"
	square = Square.new(
		x: x,
		y: y,
		size: 10,
		color: 'green'
	)
	$active_squares[key] = square
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

# Start button
$start_btn_container = Rectangle.new(
	x: 10,
	y: 10,
	width: 80,
	height: 30,
	color: '#ffffff'
)
$start_btn_inner = Rectangle.new(
	x: 11,
	y: 11,
	width: 78,
	height: 28,
	color: '#000000'
)
$start_btn_text = Text.new(
	'BEGIN',
	x: 17,
	y: 11,
	color: 'green'
)

# This works because Ruby uses integer division when both
# operands are integers. When you divide an integer by another integer
# it automatically TRUNCATES (rounds down) to the nearest whole number.
# This is the rounding outcome we want, we just have to multiply 
# by 10 then to get back to the nearest 10
def round_down_to_nearest_ten(n)
  (n / 10) * 10
end

def start_game
	$start_btn_container.remove
	$start_btn_inner.remove
	$start_btn_text.remove
	$game_started = true
end

def count_neighbors(x, y)
	neighbor_keys = [
		"#{x + 10},#{y}",      # right
		"#{x - 10},#{y}",      # left
		"#{x},#{y - 10}",      # top
		"#{x},#{y + 10}",      # bottom
		"#{x + 10},#{y - 10}", # top-right
		"#{x + 10},#{y + 10}", # bottom-right
		"#{x - 10},#{y - 10}", # top-left
		"#{x - 10},#{y + 10}"  # bottom-left
	]

	neighbor_keys.count { |key| $active_squares[key] }
end

def get_all_potential_squares
	potential_squares = Set.new

	$active_squares.each_value do |square|
		# add the current alive square
		potential_squares.add([square.x, square.y])

		# add all neighbors (potential birth locations)
		# -10 previous, 10 next (for x and y)
		[-10, 0, 10].each do |dx|
			[-10, 0, 10].each do |dy|
				next if dx == 0 && dy == 0
				potential_squares.add([square.x + dx, square.y + dy])
			end
		end
	end

	potential_squares
end

# event handlers
on :key_down do |event|
	close if event.key == 'escape' 
end

on :mouse_down do |event|
	if $start_btn_container.contains? event.x, event.y
		start_game()
	elsif $game_started
		puts 'no clicky'
	else
		$mouse_is_clicked = true
	end
end

on :mouse_up do
	$mouse_is_clicked = false
end

on :mouse_move do |event|
	if $mouse_is_clicked
		x = round_down_to_nearest_ten(event.x)
		y = round_down_to_nearest_ten(event.y)
		toggle_square(x, y)
	end
end


# animation loop
update do
	if $game_started && Window.frames % 10 == 0
		potential_squares = get_all_potential_squares
		squares_to_add = []
		squares_to_remove = []

		potential_squares.each do |x, y|
			key = "#{x},#{y}"
			neighbor_count = count_neighbors(x, y)
			is_alive = $active_squares[key]

			if is_alive
				# square dies if it doesn't have 2 or 3 neighbors
				if neighbor_count != 2 && neighbor_count != 3
					squares_to_remove << [x, y]
				end
			else
				# dead squares spring to life if they have 3 neighbors
				if neighbor_count == 3
					squares_to_add << [x, y]
				end
			end
		end

		# apply changes after evaluation
		squares_to_remove.each { |x, y| remove_square(x, y) }
		squares_to_add.each { |x, y| add_square(x, y)}
	end
end

show