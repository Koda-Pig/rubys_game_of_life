require 'ruby2d'

GAME_WIDTH = 600
GAME_HEIGHT = 400
$game_started = false
$active_squares = {}

set title: "ruby's game of life"
set width: GAME_WIDTH
set height: GAME_HEIGHT

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

def draw_square(x, y)
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
		draw_square(x, y)
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

def update_square(square)
	neighbor_right = {x: square.x + 10, y: square.y}
	neighbor_left = {x: square.x - 10, y: square.y}
	neighbor_top = {x: square.x, y: square.y - 10}
	neighbor_bottom = {x: square.x, y: square.y + 10}
	neighbor_top_right = {x: square.x + 10, y: square.y - 10}
	neighbor_bottom_right = {x: square.x + 10, y: square.y + 10}
	neighbor_top_left = {x: square.x - 10, y: square.y - 10}
	neighbor_bottom_left = {x: square.x - 10, y: square.y + 10}

	neighbors = [
		neighbor_right,
		neighbor_left,
		neighbor_top,
		neighbor_bottom,
		neighbor_top_right,
		neighbor_bottom_right,
		neighbor_top_left,
		neighbor_bottom_left
	]

	neighbor_count = neighbors.count do |neighbor|
		$active_squares[{neighbor.x, neighbor.y}]
	end

	if neighbor_count == 2 || neighbor_count == 3
		puts 'keep alive'
	else
		remove_square(square.x, square.y)
	end
end


# event handlers
on :key_down do |event|
	close if event.key == 'escape' 
end

on :mouse_down do |event|
	if $game_started
		puts 'no clicky'
	elsif $start_btn_container.contains? event.x, event.y
		start_game()
	else
		x = round_down_to_nearest_ten(event.x)
		y = round_down_to_nearest_ten(event.y)
		toggle_square(x, y)
	end
end

# animation loop
update do
	if $game_started
		$active_squares.each_value do |square|
			update_square(square)
		end
	end
end

show