require_relative 'grid'
require_relative 'ui'

def round_down(n, size)
  (n / size) * size
end

class GameOfLife
	attr_accessor :game_started, :speed, :ui

	def initialize(width, height, block_size)
		@width = width
		@height = height
		@block_size = block_size
		@game_started = false
		@active_squares = {}
		@mouse_is_clicked = false
		@drag_mode = nil # :add / :remove
		@squares_to_add = []
		@squares_to_remove = []
		Grid.new(@width, @height, @block_size, '#111111')
		@ui = UI.new(@width, @height)
		@speed = 10
	end

	def add_square(x, y)
		key = "#{x},#{y}"
		square = Square.new(
			x: x, y: y,
			size: @block_size,
			color: [0, 1, rand(), 1],
		)
		@active_squares[key] = square
		@ui.alert_message.remove if @ui.alert_message.respond_to?(:remove)
	end

	def remove_square(x, y)
		key = "#{x},#{y}"
		return unless @active_squares[key]
		@active_squares[key].remove
		@active_squares.delete(key)
	end

	def wraparound(x, y)
		x = 0 if x >= @width
		x = @width - @block_size if x < 0
		y = 0 if y >= @height
		y = @height - @block_size if y < 0
		return [x, y]
	end

	def click_start
		if !@game_started
			if @active_squares.length == 0
				@ui.alert_message.add
			else
				@ui.alert_message.remove if @ui.alert_message.respond_to?(:remove)
				@ui.button_text.text = 'RESET'
				@game_started = true
			end
		else
			@ui.button_text.text = 'BEGIN'
			@active_squares.each_value { |square| square.remove }
			@active_squares = {}
			@squares_to_add = []
			@squares_to_remove = []
			@game_started = false
		end
	end

	def count_neighbors(x, y)
		neighbor_offsets = [
			[@block_size, 0],                    # right
			[-@block_size, 0],                   # left
			[0, -@block_size],                   # top
			[0, @block_size],                    # bottom
			[@block_size, -@block_size],         # top-right
			[@block_size, @block_size],          # bottom-right
			[-@block_size, -@block_size],        # top-left
			[-@block_size, @block_size]          # bottom-left
		]

		neighbor_offsets.count do |dx, dy|
			nx = x + dx
			ny = y + dy

			nx, ny = wraparound(nx, ny)

			key = "#{nx},#{ny}"
			@active_squares[key]
		end
	end

	def get_all_potential_squares
		potential_squares = Set.new
	
		@active_squares.each_value do |square|
			# add the current alive square
			potential_squares.add([square.x, square.y])
	
			# add all neighbors (potential birth locations)
			[-@block_size, 0, @block_size].each do |dx|
				[-@block_size, 0, @block_size].each do |dy|
					next if dx == 0 && dy == 0

					nx = square.x + dx
					ny = square.y + dy

					
					
					potential_squares.add(wraparound(nx, ny))
				end
			end
		end
	
		potential_squares #returns automatically (thanks Ruby!)
	end

	def handle_mouse_down(event)
		if @ui.start_button.contains? event.x, event.y
			click_start()
			@ui.start_button.color = '#00ff00'
		elsif @ui.speed_down_btn.contains? event.x, event.y
			@speed += 2 if @speed < 60
			@ui.speed_down_btn.color = '#00ff00'
		elsif @ui.speed_up_btn.contains? event.x, event.y
			@speed -= 2 if @speed > 2
			@ui.speed_up_btn.color = '#00ff00'
		else
			@mouse_is_clicked = true
			x = round_down(event.x, @block_size)
			y = round_down(event.y, @block_size)
	
			# determine drag mode based on what's in the clicked position
			key = "#{x},#{y}"
			if @active_squares[key]
				@drag_mode = :remove
				remove_square(x, y)
			else
				@drag_mode = :add
				add_square(x, y)
			end
		end
	end

	def handle_mouse_up
		@mouse_is_clicked = false
		@drag_mode = nil 
		@ui.reset_btn_colors()
	end

	def handle_mouse_move(event)
		if @mouse_is_clicked && !@game_started
			x = round_down(event.x, @block_size)
			y = round_down(event.y, @block_size)
			key = "#{x},#{y}"
	
			if @drag_mode == :add && !@active_squares[key]
				add_square(x, y)
			elsif @drag_mode == :remove && @active_squares[key]
				remove_square(x, y)
			end
		end
	end

	def handle_click_start
		if @game_started
			reset_game()
		else
			start_game()
		end
	end

	def start_game
		if @active_squares.length == 0
			@ui.alert_message.add
		else
			@ui.alert_message.remove if @ui.alert_message.respond_to?(:remove)
			@ui.button_text.text = 'RESET'
			@game_started = true
		end
	end

	def reset_game
		@ui.button_text.text = 'BEGIN'
		@active_squares.each_value { |square| square.remove }
		@active_squares = {}
		@squares_to_add = []
		@squares_to_remove = []
		@game_started = false
	end

	def update
		potential_squares = get_all_potential_squares

		potential_squares.each do |x, y|
			key = "#{x},#{y}"
			neighbor_count = count_neighbors(x, y)
			is_alive = @active_squares[key]

			if is_alive
				# square dies if it doesn't have 2 or 3 neighbors
				@squares_to_remove << [x, y] if neighbor_count != 2 && neighbor_count != 3
			else
				# dead squares spring to life if they have 3 neighbors
				@squares_to_add << [x, y] if neighbor_count == 3
			end
		end

		# apply changes after evaluation
		@squares_to_remove.each { |x, y| remove_square(x, y) }
		@squares_to_add.each { |x, y| add_square(x, y)}

		# Clear arrays for next generation
		@squares_to_add = []
		@squares_to_remove = []
	end
end
