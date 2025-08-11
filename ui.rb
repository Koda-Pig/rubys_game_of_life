class UI
	attr_accessor :start_button,
								:speed_down_btn,
								:speed_up_btn,
								:button_text,
								:speed_text,
								:alert_message

	def initialize(width, height, speed)
		@width = width
		@height = height
		@speed = speed

		# start/ restart btn
		@start_button = Rectangle.new( x: 10, y: 10, width: 80, height: 30, color: '#ffffff', z: 1 )
		Rectangle.new( x: 11, y: 11, width: 78, height: 28, color: '#444444', z: 1 )
		@button_text = Text.new( 'BEGIN', x: 17, y: 11, color: 'green', z: 1 )
		@speed_text = Text.new( @speed, x: 180, y: 11, color: 'green', z: 1 )
		@alert_message = Text.new(
			'DRAW SOME SQUARES FIRST!',
			x: @width / 2 - 50 * 8,
			y: @height / 2 - 50,
			color: 'white',
			size: 50,
			show: false,
			z: 1
		)

		# speed btns
		@speed_down_btn = Rectangle.new( x: 100, y: 10, width: 30, height: 30, color: '#ffffff', z: 1 )
		Rectangle.new( x: 101, y: 11, width: 28, height: 28, color: '#444444', z: 1 )
		Rectangle.new( x: 108, y: 24, width: 15, height: 2, color: '#ffffff', z: 1 )
		
		@speed_up_btn = Rectangle.new( x: 140, y: 10, width: 30, height: 30, color: '#ffffff', z: 1 )
		Rectangle.new( x: 141, y: 11, width: 28, height: 28, color: '#444444', z: 1 )
		Rectangle.new( x: 148, y: 24, width: 15, height: 2, color: '#ffffff', z: 1 )
		Rectangle.new( x: 154, y: 18, width: 2, height: 15, color: '#ffffff', z: 1 )
	end

	def reset_btn_colors
		@speed_down_btn.color = '#ffffff'
		@speed_up_btn.color = '#ffffff'
		@start_button.color = '#ffffff'
	end

	def update_speed_ui(new_speed, min_speed, max_speed)
		speed_percentage = ((max_speed - new_speed) / (max_speed - min_speed) * 100).round
		@speed_text.text = "#{speed_percentage}%"
	end
end
