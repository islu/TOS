#coding: utf-8
require 'gosu'
require 'aasm'
require_relative 'stone'
require_relative 'board'
require_relative 'timebar'
require_relative 'team'

class BATTLE_STATE
  include AASM
  aasm do
    state :normal, initial: true
    state :moveing,:deleting,:dropping,:checking,:attacking,:first_checking
			
		event :move do
			transitions from: :normal, to: :moveing
		end
		event :active do
			transitions from: :normal, to: :first_checking
		end
		
		event :delete do
			transitions from: :moveing, to: :deleting
		end		
		event :drop do
			transitions from: [:deleting,:checking], to: :dropping
		end
		event :again do
			transitions from: :dropping, to: :deleting
		end
		event :check do
			transitions  from: :dropping, to: :checking
		end
		event :attack do
			transitions from: :checking, to: :attacking
		end
		
		# test
		event :back do
			transitions from: [:first_checking,:moveing,:deleting,:dropping,:attacking], to: :normal
		end
		
	end
end

class Game < Gosu::Window
	
	def initialize
		super 480,720
		#super 1200,720
		self.caption = "ToS"
		@board = Board.new
		@team = Team.new([1239,1239,1239,1239,1239,1239])
		@timebar = Timebar.new(@team.maxLife)
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
		if button_down?(Gosu::MS_LEFT) and @state.may_move?
			if @board.stone?(mx,my)
				@board.reset_combo_counter
				@board.drag(mx,my)
				@board.swap(mx,my) and @state.move
			end
			if @team.monster?(mx,my)
				index = @team.index(mx,my)
				active_monster_skill(index)
			end
		end
		# 轉珠中
		if button_down?(Gosu::MS_LEFT) and @state.moveing?
			# 時間結束計算combo		
			@timebar.countdown(currtime) and @state.delete and @board.check_combos
		end
		if button_down?(Gosu::MS_LEFT) and @state.moveing? and @board.stone?(mx,my)
			@board.drag(mx,my)
			@board.swap(mx,my)
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
					@state.check
				else
					@state.again
				end
			end
		end
		if @state.checking?
			if @board.explode_h
				@state.drop and @board.search_dropping
			else
				@state.attack
			end
		end
		
		# 計算傷害
		if @state.attacking?
			@state.back
		end
		
		if @state.first_checking?
			@state.back
		end
		
		!button_down?(Gosu::MS_LEFT) || @state.deleting? and @board.reset	
		
		@timebar.update_life(@team.currLife)
		# test
		button_down?(Gosu::KB_Q) and @board.new
		
	end
	
	def draw
		mx,my = mouse_x,mouse_y
		sx,sy = width,height
		@board.draw
		
		@team.draw_icons
		@state.normal? and @team.monster?(mx,my) and @team.draw_skills(@team.index(mx,my))
		
		!@state.normal? and !@state.moveing? and @board.draw_combo
		!@state.moveing? and @timebar.draw_lifebar
		@state.moveing? and @timebar.draw_timebar

		
		@debug.draw_text("#{mx} , #{my}", 0, 0, 2, 1.0, 1.0, Gosu::Color::WHITE)
		
		#@debug.draw_text("index? #{@team.index(mx,my)}", 0, 50, 2, 1.0, 1.0, Gosu::Color::WHITE)

	end
	
	def active_monster_skill(monsterOrder)
		monsterId = @team.id(monsterOrder)
		case monsterId
			when 1239
				@board.all_transform
				@board.enchante("_f")
		end
		@state.active
	end
	
end

Game.new.show
