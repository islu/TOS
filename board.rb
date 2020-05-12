class Board
	def initialize
		
		@stones = []
		@boardback = []
		@col,@row = 5,6
		@stonesize = 80
		@ybias = 320
		@currstone = nil
		
		@combostack = []
		@temptime = 0.0
		@deletspeed = 450.0
		@combocounter = 0
		@combosound = ComboSound.new
		@combotext = Gosu::Font.new(50)
		@combotext2 = Gosu::Font.new(30)
		@comboMagn = 0.25
		
		@dropstack = []
		@trun = 0
		
		@record = {
			"_w"=>0,"_f"=>0,"_e"=>0,"_l"=>0,"_d"=>0,"_h"=>0,
			"_w_en"=>0,"_f_en"=>0,"_e_en"=>0,"_l_en"=>0,"_d_en"=>0,"_h_en"=>0
		}
		
		init
	end
	def drop(attr)
		
	end
	
	def explode(attr)
		c = []
		@stones.each_index {|i|
			c<<i if @stones[i].attr == attr
		}
		return false if c.empty?
		c.each {|i|
			@stones[i].nostone
			@stones[i].update_img
		}
		return true
	end
	def explode_h; explode("_h"); end;
	
	
	def dropping
		done = true
		@stones.each_index do |i|
			x,y = coord(i)
			if @stones[i].y != y*@stonesize+@ybias
				@stones[i].drop
				done = false
			end
		end
		return done
	end
	
	def search_dropping
		len = @stones.length
		temp = []
		(len-1).downto(0) do |i|
			if @stones[i].deleted?
				j = dfs_up(i-6)	
				if j.nil?
					temp<<i
				else	
					@stones[i],@stones[j] = @stones[j],@stones[i]
				end
			end
		end
		
		temp.shuffle!
		unless @dropstack.empty? || temp.empty?
			attr = @dropstack.pop
			i = temp.pop
			x,y = coord(i)
			@stones[i].new(attr,"_en")
			@stones[i].set(x*@stonesize,y*@stonesize+80)	
		end

		temp.each do |i|
			x,y = coord(i)
			@stones[i].new
			@stones[i].set(x*@stonesize,y*@stonesize+80)		
		end
	end
	
	def dfs_up(i)
		return nil if i < 0
		if @stones[i].deleted?
			dfs_up(i-6)
		else 
			return i
		end
	end
	
	def delete_combos(currtime)
		if @temptime < currtime
			@temptime = currtime+@deletspeed
			delete
		end
	end
	
	def reset_combo_counter
		@combocounter = 0
		@record = {
			"_w"=>0,"_f"=>0,"_e"=>0,"_l"=>0,"_d"=>0,"_h"=>0,
			"_w_en"=>0,"_f_en"=>0,"_e_en"=>0,"_l_en"=>0,"_d_en"=>0,"_h_en"=>0
		}
	end
	def delete
		c = @combostack.pop
		return nil if c == nil
		@dropstack<<@stones[c.last].attr if c.length >= 5
		@combocounter += 1
		@combosound.play(@combocounter)
		
		c.each {|i|
			attr = @stones[i].attr
			en = @stones[i].en
			# 紀錄符石屬性數量及強化數量
			@record["#{attr}#{en}"] += 1
			@stones[i].nostone
			@stones[i].update_img
		}

	end

	
	def all_delete?
		@combostack.empty?
	end
	
	def check_combos
		# check row
		@combostack = []
		combo = []
		for i in 0...@col
			for j in 0...@row
				index = i*@row+j
				if combo.empty? or same_stone?(combo.last,index)
					combo<<index
				else 
					@combostack<<combo if combo.length >= 3
					combo = []
					combo<<index
				end
			end
			@combostack<<combo if combo.length >= 3
			combo = []
		end
		# check col
		combo = []
		for i in 0...@row
			for j in 0...@col
				index = i+j*@row
				if combo.empty? or same_stone?(combo.last,index)
					combo<<index
				else 
					@combostack<<combo if combo.length >= 3
					combo = []
					combo<<index
				end
			end
			@combostack<<combo if combo.length >= 3
			combo = []
		end
		# merge combostack		
		tempcombostack = []
		tempcombo = []
		visited = []
		len = @combostack.length
		for i in 0...len
			next if visited.include?(i)
			tempcombo = @combostack[i]
			for j in i+1...len
				next if visited.include?(j)
				c1,c2 = @combostack[i],@combostack[j]
				if same_stone?(c1.last,c2.last) and merge?(c1,c2)
					tempcombo = tempcombo.union(c2)
					visited<<j
				end
			end
			tempcombostack<<tempcombo
		end
		
		@combostack = tempcombostack

		return @combostack
	end
	
	def merge?(combo1, combo2)
		return false if combo1==nil or combo2==nil
		combo1.each {|c| combo2.include?(c) and return true }
		
		combo1.each do |c| 
			neig = neighbor_index(c)
			neig.each {|n| combo2.include?(n) and return true }
		end
		
		return false
	end
	
	def neighbor_index(i)
		neighbors = []
		neighbors<<i+1 if i/6 == (i+1)/6
		neighbors<<i-1 if i/6 == (i-1)/6
		neighbors<<i-6 if i-6 >= 0
		neighbors<<i+6 if i+6 < @row*@col
		return neighbors
	end
	
	def same_stone?(i1,i2)
		@stones[i1].attr == @stones[i2].attr
	end
	
	def stone?(mx,my)
		!(my<@ybias || my>@ybias+@stonesize*@col || mx<0 || mx>@stonesize*@row)
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
	def draw_combo
		@combotext.draw_text("#{@combocounter} combo!!", 250, 650, 2, 1.0, 1.0, Gosu::Color::YELLOW)	
		@combotext2.draw_text("+#{@combocounter*@comboMagn*100.0}%", 330, 625, 2, 1.0, 1.0, Gosu::Color::YELLOW)	
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

class ComboSound
	def initialize
		@sound = []
		init
	end
	def play(i)
		if i >= 9
			@sound[-1].play
		else
			@sound[i-1].play
		end
	end
	private
	def init
		10.times {|i| @sound<<Gosu::Sample.new("sound/combo/combo#{i+1}.wav") }
	end
end
