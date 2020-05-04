#coding: utf-8
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
		event :drop do
			transitions from: :deleting, to: :dropping
		end
		event :again do
			transitions from: :dropping, to: :deleting
		end
		event :next do
			transitions from: :dropping, to: :normal
		end
		
		# test
		event :back do
			transitions from: [:dropping], to: :normal
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
		
		# 轉珠前
		if button_down?(Gosu::MS_LEFT) and @state.may_move? and @board.stone?(mx,my,sx,sy)
			@board.reset_combo_counter
			@board.drag(mx,my)
			@board.swap(mx,my) and @state.move
		end
		# 轉珠中
		if button_down?(Gosu::MS_LEFT) and @state.moveing? and @board.stone?(mx,my,sx,sy)
			@board.drag(mx,my)
			@board.swap(mx,my)
			# 時間結束計算combo
			@timebar.countdown(currtime) and @state.delete and @board.check_combos
		elsif !button_down?(Gosu::MS_LEFT) and @state.moveing?
			@timebar.reset_timebar
			# 放開後珠子計算combo
			@board.check_combos
			@state.delete
		end
		# 刪除動畫
		if @state.deleting?
			@board.all_delete? and @state.drop and @board.search_dropping
			@board.delete_combos(currtime)
		end
		
		if @state.dropping?
			if @board.dropping
				@board.check_combos
				if @board.all_delete?
					@state.next 
				else
					@state.again
				end
			end
		end
		
		
		!button_down?(Gosu::MS_LEFT) and @board.reset
		# test
		button_down?(Gosu::KB_Q) and @state.dropping? and @state.back and @board.new
		#@state.dropping? and @state.back and @board.new
	end
	
	def draw
		mx,my = mouse_x,mouse_y
		sx,sy = width,height
		@board.draw
		@state.deleting? || @state.dropping? and @board.draw_combo
		!@state.moveing? and @timebar.draw_lifebar
		@state.moveing? and @timebar.draw_timebar
		
		
		@debug.draw_text("#{mx} , #{my}", 0, 0, 2, 1.0, 1.0, Gosu::Color::WHITE)
		@debug.draw_text("dropping? #{@state.dropping?}", 0, 25, 2, 1.0, 1.0, Gosu::Color::WHITE)

	end
end

Game.new.show
