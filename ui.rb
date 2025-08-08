class UI
	attr_accessor :button_container, :button_text, :alert_message

	def initialize(width, height)
		@width = width
		@height = height
		@button_container = Rectangle.new( x: 10, y: 10, width: 80, height: 30, color: '#ffffff', z: 1 )
		Rectangle.new( x: 11, y: 11, width: 78, height: 28, color: '#444444', z: 1 )
		@button_text = Text.new( 	'BEGIN', 	x: 17, 	y: 11, 	color: 'green', 	z: 1 )
		@alert_message = Text.new(
			'DRAW SOME SQUARES FIRST!',
			x: @width / 2 - 50 * 8,
			y: @height / 2 - 50,
			color: 'white',
			size: 50,
			show: false,
			z: 1
		)
	end
end
