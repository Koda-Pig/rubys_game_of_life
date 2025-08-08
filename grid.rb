class Grid
	def initialize(width, height, block_size, color = '#333333')
		@width = width
		@height = height
		@block_size = block_size
		@color = color

		draw()
	end

	def draw
		# Draw horizontal lines
		(0...@height).each do |i|
			if i % @block_size == 0
				Line.new(
					x1: 0, y1: i,
					x2: @width, y2: i,
					width: 1,
					color: @color
				)
			end
		end

		# Draw vertical lines
		(0...@width).each do |i|
			if i % @block_size == 0
				Line.new(
					x1: i, y1: 0,
					x2: i, y2: @height,
					width: 1,
					color: @color
				)
			end
		end
	end
end
