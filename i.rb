require 'ruby2d'

GAME_WIDTH = 600
GAME_HEIGHT = 400

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
start_btn_container = Rectangle.new(
	x: 10,
	y: 10,
	width: 150,
	height: 80,
	color: '#ffffff'
)
start_btn_b = Rectangle.new(
	x: 11,
	y: 11,
	width: 148,
	height: 78,
	color: '#000000'
)


# This works because Ruby uses integer division when both
# operands are integers. When you divide an integer by another integer
# it automatically TRUNCATES (rounds down) to the nearest whole number.
# This is the rounding outcome we want, we just have to multiply 
# by 10 then to get back to the nearest 10
def round_down_to_nearest_ten(n)
  (n / 10) * 10
end

# event handlers
on :key_down do |event|
	close if event.key == 'escape' 
end

on :mouse_down do |event|
	if start_btn_container.contains? event.x, event.y
		puts "oh no you fickun dont"
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