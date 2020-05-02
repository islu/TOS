require 'gosu'
require 'aasm'
require_relative 'stone'
require_relative 'board'
require_relative 'timebar'

class BATTLE_STATE
  include AASM
  aasm do
    state :normal, initial: true
    state :moveing,:deleting,:dropping
			
		event :move do
			transitions from: :normal, to: :moveing
		end
		event :delete do
			transitions from: :moveing, to: :deleting
		end
		
		# test
		event :back do
			transitions from: [:moveing,:deleting,:dropping], to: :normal
		end
		
	end
end

class Game < Gosu::Window
	
	def initialize
		super 480,720
		self.caption = "ToS"
		@board = Board.new
		@timebar = Timebar.new
		@state = BATTLE_STATE.new
		@debug = Gosu::Font.new(25)
		
	end
	def needs_cursor?; true; end

	def update
		mx,my = mouse_x,mouse_y
		sx,sy = width,height
		currtime = Gosu.milliseconds
		
		button_down?(Gosu::KB_ESCAPE) and exit
		
		if button_down?(Gosu::MS_LEFT) and @state.may_move? and @board.stone?(mx,my,sx,sy)
			@board.drag(mx,my)
			@board.swap(mx,my) and @state.move
		end
		
		if button_down?(Gosu::MS_LEFT) and @state.moveing? and @board.stone?(mx,my,sx,sy)
			@board.drag(mx,my)
			@board.swap(mx,my)
			@timebar.countdown(currtime) and @state.delete
		elsif !button_down?(Gosu::MS_LEFT) and @state.moveing?
			@timebar.reset_timebar
			@state.delete
		end
		
		# test
		@state.deleting? and @state.back
		
		!button_down?(Gosu::MS_LEFT) and @board.reset

		#button_down?(Gosu::KB_Q) and @board.new
	end
	
	def draw
		mx,my = mouse_x,mouse_y
		sx,sy = width,height
		@board.draw
		!@state.moveing? and @timebar.draw_lifebar
		@state.moveing? and @timebar.draw_timebar
		
		@debug.draw_text("#{mx} , #{my}", 0, 0, 2, 1.0, 1.0, Gosu::Color::WHITE)
		@debug.draw_text("deleting?: #{@state.deleting?}", 0, 50, 2, 1.0, 1.0, Gosu::Color::WHITE)
	end
end

Game.new.show
