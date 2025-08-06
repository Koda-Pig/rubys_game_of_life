require 'ruby2d'

set title: "ruby's game of life"
set width: 600
set height: 400

# event handlers
on :key_down do |event|
	if event.key == 'escape'
		close
	end
end

# animation loop
update do
	puts "hi mom"
end

show