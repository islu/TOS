class Timebar
	def initialize(maxLife,t=5000.0)
		@ybias = 320
		@inonscale = 0.6
		@font = Gosu::Font.new(25)
		@clock = Image.new("image/Timebar/clock.png",0,0,1)
		@heart = Image.new("image/Timebar/heart.png",0,0,1)
		@timeclip = Image.new("image/Timebar/timeclip.png",0,0,1)
		@lifeclip = Image.new("image/Timebar/lifeclip.png",0,0,1)
		
		@basedtime = t
		@extratime = 0
		@temptime = 0.0
		@clipsale = 0.8
		
		@currLife,@maxLife = maxLife,maxLife 
		
		init
	end
	
	def update_life(currLife)
		@currLife = currLife
	end

	def draw_lifebar
		diff = (@maxLife-@currLife)/@maxLife.to_f
		@lifeclip.set(@heart.w*@inonscale/2-diff*@lifeclip.w,@ybias-@lifeclip.h)
		
		@lifeclip.draw(1,@clipsale)
		@heart.draw(@inonscale,@inonscale)
		@font.draw_text("#{@currLife}/#{@maxLife}",320,290,2,1.0,1.0,Gosu::Color::YELLOW)
	end

	def draw_timebar
		@timeclip.draw(1,@clipsale)
		@clock.draw(@inonscale,@inonscale)
	end
	def draw_re(totalRe)
		if totalRe != 0
			@font.draw_text("+#{totalRe}",200,285,2,1.0,1.0,Gosu::Color.argb(0xff_1AFD9C))
		end
	end
	
	def countdown(currtime)
		@temptime < currtime and @temptime = currtime+@basedtime+@extratime
		difftime = 1.0-(@temptime-currtime)/(@basedtime+@extratime)
		@timeclip.set(@clock.w*@inonscale/2-difftime*@timeclip.w,@ybias-@timeclip.h)
		# 倒數結束
		return true if difftime > 0.98
	end
	
	def reset_timebar
		@temptime = 0.0
	end
	
	def add_time(time)
		@extratime = time
	end
	
	private
	def init
		@clock.set(0,@ybias-@clock.h*@inonscale)
		@heart.set(0,@ybias-@heart.h*@inonscale)
		@timeclip.set(@clock.w*@inonscale/2,@ybias-@timeclip.h)
		@lifeclip.set(@heart.w*@inonscale/2,@ybias-@lifeclip.h)
	end
end