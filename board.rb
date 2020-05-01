class Board
	def initialize
		@stones = []
		@boardback = []
		@col,@row = 5,6
		@stonesize = 80
		@ybias = 320
		@combos = []
		
		@currstone = nil
		init
	end
	
	def stone?(mx,my,sx,sy)
		!(my<@ybias || my>sy || mx<0 || mx>sx)
	end
	# 交換符石
	def swap(mx,my)
		i = index(mx,my)
		if i != @currstone
			@stones[i],@stones[@currstone] = @stones[@currstone],@stones[i]
			# 重新定位符石位置
			x,y = coord(@currstone)
			@stones[@currstone].set(x*@stonesize,y*@stonesize+@ybias)
			@currstone = i
			return true
		else
			return false
		end
	end
	def drag(mx,my)
		i = index(mx,my)
		@currstone = i if @currstone == nil
		@stones[@currstone].drag(mx,my)
	end

	# 重新定位被點擊符石的位置
	def reset
		if @currstone != nil
			x,y = coord(@currstone)
			@stones[@currstone].set(x*@stonesize,y*@stonesize+@ybias)
		@currstone = nil		
		end
	end
	
	def index(mx,my)
		x,y = (mx/@stonesize).floor,((my-@ybias)/@stonesize).floor
		return y*6+x
	end
	def coord(i)
		x,y = i%6,i/6
		return x,y
	end
	# 產生新的盤面
	def new
		@stones.each {|stone| 
			stone.transform_to_random
			stone.update_img
		}
	end
	def draw
		@stones.each {|stone| stone.draw}
		@boardback.each {|img| img.draw}
	end
	private
	def init
		c = 0
		for i in 0...@col
			for j in 0...@row
				@stones << Stone.new(j*@stonesize,i*@stonesize+@ybias)
				@boardback << Image.new("image/board_back_#{c%2+1}.png",j*@stonesize,i*@stonesize+@ybias,0)
				c += 1
			end
			c += 1
		end		
	end
end