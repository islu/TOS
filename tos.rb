require 'gosu'

class Image
  def initialize(img,x,y,z)
		@img = Gosu::Image.new(img)
		@w,@h = @img.width,@img.height
		@x,@y,@z = x,y,z
  end
	def draw
		@img.draw(@x,@y,@z)
	end
end

class Stone < Image
	attr_reader :attr, :dis, :color
	def initialize(color,x,y)
		super "image/stone_#{color}.png",x,y,1
		@color = color
		@visited = false
		@attr = 0
		@dis = 0
	end
	def drag(x,y)
		@x,@y = x-@w/2,y-@h/2
	end
	def set(x,y)
		@x,@y = x,y
	end
	def set_attr(n)
		@attr = n
	end
	def visited?
		@visited
	end
	def visited=(bool)
		@visited = bool
	end
end

class Board
	def initialize
		@b = []
		@colors = ["w","f","e","l","d","h"]
		@size = 80
		@yOffset = 320
		
		@bb = []
		@isMove = false
		@start = 0
		@combos = []
		
		new_board
	end
	def draw
		@b.each {|s| s.draw}
		@bb.each {|s| s.draw}
	end

	def index(x,y,mode = 0)
		xIndex,yIndex = (x/@size).floor,((y-@yOffset)/@size).floor
		#return (x/@size).floor, ((y-@YOffset)/@size).floor
		return yIndex*6+xIndex if mode == 0
		return xIndex,yIndex if mode == 1
	end
	def dindex(index)
		x = index % 6
		y = index / 6
		return x,y
	end
 
	def stone?(x,y,sx,sy)
		if y<@yOffset or y>sy or x<0 or x>sx
			return false
		else
			return true
		end	
	end
	
	def move?
		@isMove
	end
	def move=(m)
		@isMove = m 
	end
	def start=(i)
		@start = i
	end
	def start
		@start
	end
	
	def drag(s,x,y)
		@b[s].drag(x,y)
	end
	def swap(s1,s2)
		@b[s1],@b[s2] = @b[s2],@b[s1]
	end
	def set_stone(s,x,y)
		@b[s].set(x*@size,y*@size+@yOffset)
		#puts "第幾#{s}顆 color:#{@b[0].color} x:#{x} y:#{y}"
		#puts "#{x*@size} #{y*@size+@yOffset}"
	end
	
	def check
		@combos = []
		@b.each {|s| s.visited = false}
		@b.each_index do |i|
			temp = DFS_combo(i,[])
			@combos << temp if !temp.empty?
		end
		return "共#{@combos.length}組,#{@combos}"
	end
	
	def DFS_combo(i,set)
		# check right 1&2
		if i/6==(i+1)/6 and i/6==(i+2)/6 and @b[i].color==@b[i+1].color and @b[i].color==@b[i+2].color
			set << i if !@b[i].visited?
			@b[i].visited = true
			if !@b[i+1].visited?
				set << i+1
				@b[i+1].visited = true
				DFS_combo(i+1,set)
			end
			if !@b[i+2].visited?
				set << i+2
				@b[i+2].visited = true
				DFS_combo(i+2,set)
			end
		end
		# check left 1&2
		if i-1>0 and i-2>0 and i/6==(i-1)/6 and i/6==(i-2)/6 and @b[i].color==@b[i-1].color and @b[i].color==@b[i-2].color			
			set << i if !@b[i].visited?
			@b[i].visited = true
			if !@b[i-1].visited?
				set << i-1
				@b[i-1].visited = true
				DFS_combo(i-1,set)
			end
			if !@b[i-2].visited?
				set << i-2
				@b[i-2].visited = true
				DFS_combo(i-2,set)
			end		
		end
		# check left 1 right 1
		if i-1>0 and i/6==(i-1)/6 and i/6==(i+1)/6 and @b[i].color==@b[i-1].color and @b[i].color==@b[i+1].color			
			set << i if !@b[i].visited?
			@b[i].visited = true
			if !@b[i-1].visited?
				set << i-1
				@b[i-1].visited = true
				DFS_combo(i-1,set)
			end
			if !@b[i+1].visited?
				set << i+1
				@b[i+1].visited = true
				DFS_combo(i+1,set)
			end
			end
		end
		# check below 1&2
		if i+6<30 and i+12<30 and i%6==(i+6)%6 and i%6==(i+12)%6 and @b[i].color==@b[i+6].color and @b[i].color==@b[i+12].color
			set << i if !@b[i].visited?
			@b[i].visited = true
			if !@b[i+6].visited?
				set << i+6
				@b[i+6].visited = true
				DFS_combo(i+6,set)
			end
			if !@b[i+12].visited?
				set << i+12
				@b[i+12].visited = true
				DFS_combo(i+12,set)
			end
		end
		#check up 1&2
		if i-6>0 and i-12>0 and i%6==(i-6)%6 and i%6==(i-12)%6 and @b[i].color==@b[i-6].color and @b[i].color==@b[i-12].color
			set << i if !@b[i].visited?
			@b[i].visited = true
			if !@b[i-6].visited?
				set << i-6
				@b[i-6].visited = true
				DFS_combo(i-6,set)
			end
			if !@b[i-12].visited?
				set << i-12
				@b[i-12].visited = true
				DFS_combo(i-12,set)
			end
		end
		#check up 1 & below 1
		if i-6>0 and i+6<30 and i%6==(i-6)%6 and i%6==(i+6)%6 and @b[i].color==@b[i-6].color and @b[i].color==@b[i+6].color
			set << i if !@b[i].visited?
			@b[i].visited = true
			if !@b[i-6].visited?
				set << i-6
				@b[i-6].visited = true
				DFS_combo(i-6,set)
			end
			if !@b[i+6].visited?
				set << i+6
				@b[i+6].visited = true
				DFS_combo(i+6,set)
			end
		end

		
		return set
	end

	private
	def new_board
		c = 0
		for i in 0..4
			for j in 0..5
				@b << Stone.new(@colors.sample,j*@size,i*@size+@yOffset)
				@bb << Image.new("image/board_back_#{c%2+1}.png",j*@size,i*@size+@yOffset,0)
				c += 1
			end
			c += 1
		end
	end
end

class Game < Gosu::Window
	def initialize
		super 480,720
		self.caption = "ToS"
		#@stone = Stone.new("f",0,0)
		@board = Board.new
		@debug = Gosu::Font.new(25)
	end
	def needs_cursor?; true; end

	def update
		#button_down?(Gosu::MS_LEFT) and @stone.drag(self.mouse_x,self.mouse_y)
		button_down?(Gosu::KB_ESCAPE) and exit
		
		if button_down?(Gosu::MS_LEFT) and @board.move?
			if @board.stone?(mouse_x,mouse_y,width,height)
				index = @board.index(mouse_x,mouse_y)
				@board.drag(index,mouse_x,mouse_y-10)
				if @board.start != index
					coord = @board.dindex(@board.start)
					@board.swap(@board.start,index)
					@board.set_stone(@board.start,coord[0],coord[1])
					@board.start = index
				end
			end
		elsif button_down?(Gosu::MS_LEFT) and @board.stone?(mouse_x,mouse_y,width,height)
			@board.move = true
			@board.start = @board.index(mouse_x,mouse_y)	
		end
	
		if !button_down?(Gosu::MS_LEFT) 
			@board.move = false
			coord = @board.dindex(@board.start)
			@board.set_stone(@board.start,coord[0],coord[1])
		end
		
		button_down?(Gosu::KB_Q) and @board.check
		
	end
	
	def draw
		@debug.draw_text("#{mouse_x} , #{mouse_y}", 0, 0, 2, 1.0, 1.0, Gosu::Color::WHITE)
		@debug.draw_text("#{@board.start}", 0, 25, 2, 1.0, 1.0, Gosu::Color::WHITE)
		@debug.draw_text("move? #{@board.move?}, stone? #{@board.stone?(mouse_x,mouse_y,width,height)}", 0, 50, 2, 1.0, 1.0, Gosu::Color::WHITE)
		@debug.draw_text(@board.check, 0, 75, 2, 1.0, 1.0, Gosu::Color::WHITE)
		#@stone.draw
		@board.draw
	end
end

Game.new.show