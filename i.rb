require 'ruby2d'

GAME_WIDTH = 600
GAME_HEIGHT = 400
$game_started = false

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
	Square.new(
		x: x,
		y: y,
		size: 10,
		color: 'green'
	)
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
		draw_square(
			round_down_to_nearest_ten(event.x),
			round_down_to_nearest_ten(event.y)
		)
	end
end

# animation loop
update do
end

show