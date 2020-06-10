class Enemy < Image
	def initialize(x,y,id,atk,hp,dfs,cd,duration,characteristic)
		@sx,@sy = 50,350
		@font = Gosu::Font.new(25)
		
		@id = id
		@atk,@hp,@dfs, = atk,hp,dfs
		@cd,@duration = cd,duration
		@characteristic = characteristic
		@attr = DATA::MONSTER[@id][:attr]
		@description = ENEMY::SKILL[@characteristic][:description]
		@maxHp = hp.to_f
		
		super "image/monster/#{@id}n.png",x,y,1
		
		line_feed
	end
	def draw(sx=0.5, sy=0.5, color=0xff_ffffff)
		@img.draw(@x,@y,@z,sx,sy,color)
		if @h == 512
			@font.draw_text("#{@cd}",@x+@w/4+65,@y+@h/4,3,1.0,1.0,Gosu::Color::YELLOW)
		elsif @h == 256 
			@font.draw_text("#{@cd}",@x+@w/4+35,@y+@h/4,3,1.0,1.0,Gosu::Color::YELLOW)
		end
		@font.draw_text("#{(@hp/@maxHp*100).ceil}%",@x+@w/4-25,@y+@h/2,1,1.0,1.0,atk_font_color(attr))
	end
	def hover?(mx,my)
		@x<=mx && mx<=@x+@w/2 && @y+@h/2>my && my>@y
	end
	def draw_skill(mx,my)
		if hover?(mx,my)
			Gosu.draw_quad(@sx-25,@sy-25,Gosu::Color::GRAY,@sx+400,@sy-25,Gosu::Color::GRAY,@sx+400,@sy+200,Gosu::Color::BLACK,@sx-25,@sy+200,Gosu::Color::BLACK,3)
			@font.draw_markup("#{DATA::MONSTER[@id][:name]} <c=00ff00>#{ENEMY::SKILL[@characteristic][:name]}</c>",@sx,@sy,3,1.0,1.0,Gosu::Color::YELLOW)
			@font.draw_text("#{@description}",@sx,@sy+50,3,1.0,1.0,Gosu::Color::YELLOW)
		end
	end
	def die?
		@hp <= 0
	end
	def take_damage(damage)
		if damage <= @dfs
			@hp -= 1
		else 
			@hp -= (damage-@dfs)
		end
	end
	def dec
		@cd -= 1 if @cd != 0
	end
	def can_attack?
		@cd == 0
	end
	def cd_reset
		@cd = @duration
	end
	def damage
		@atk
	end
	
	def characteristic; @characteristic; end
	def attr; @attr; end
	
	private
	def line_feed(maxlen=20)
		counter = 0
		str = ""
		@description.each_char {|c|
			counter += 1
			str += c
			if counter == maxlen
				str += "\n"
				counter = 0
			end
		}
		@description = str
	end
	def atk_font_color(attr)
		case attr
			when "_w"; Gosu::Color::AQUA
			when "_f"; Gosu::Color::RED
			when "_e"; Gosu::Color::GREEN
			when "_l"; Gosu::Color::YELLOW
			when "_d"; Gosu::Color::FUCHSIA
			else Gosu::Color::WHITE;
		end
	end	

end

class Floor
	def initialize(id)
		@id = id
		@waves = FLOOR_DATA::FLOOR[@id][:waves].length
		@turn = 0
		@enemys = []
		@floor = 0
		@font = Gosu::Font.new(25)
		generate_enemys
	end

	def all_clear?
		@floor == @waves
	end
	def wave_claer?
		@enemys.empty?
	end
	def next_wave
		@floor += 1
		!all_clear? and generate_enemys
	end
	def take_damage(damages)
		print "damages: "
		p damages
		targetId = 0
		damages.each do |d|
			if targetId == @enemys.length
				@enemys[0].take_damage(d)
			else 
				@enemys[targetId].take_damage(d)
				targetId += 1 if @enemys[targetId].die?
			end
		end
	end
	def damage
		result = []
		@enemys.each {|e|
			if e.can_attack?
				result << e.damage
				e.cd_reset
			end
		}
		return result
	end
	def cd_countdown
		@enemys.each(&:dec)
	end
	
	def enemys; @enemys; end
	
	def update
		@enemys.delete_if(&:die?)
		cd_countdown
		wave_claer? and next_wave
	end
	def draw_enemys
		@enemys.each(&:draw)
	end
	def draw_wave
		@font.draw_text("wave: #{@floor+1} #{FLOOR_DATA::FLOOR[@id][:name]}",0,0,1,1.0,1.0,Gosu::Color::YELLOW)
	end
	def draw_skills(mx,my)
		@enemys.each {|e| e.draw_skill(mx,my)}
	end
	private
	
	def generate_enemys
		case FLOOR_DATA::FLOOR[@id][:setting][@floor]
		when "random1"
			x,y = 180,20
			enemys = []
			enemys << FLOOR_DATA::FLOOR[@id][:waves][@floor].sample
			enemys.each do |d|
				id = d[:monsterId]
				atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
				cd,duration = d[:CD],d[:duration]
				characteristic = d[:characteristic]
				@enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
				@enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
				x += 120
			end		
		when "random2"
			x,y = 120,20
			enemys = []
			2.times {enemys << FLOOR_DATA::FLOOR[@id][:waves][@floor].sample}
			enemys.each do |d|
				id = d[:monsterId]
				atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
				cd,duration = d[:CD],d[:duration]
				characteristic = d[:characteristic]
				@enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
				@enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
				x += 120
			end
		when "random3"
			x,y = 40,20
			enemys = []
			3.times {enemys << FLOOR_DATA::FLOOR[@id][:waves][@floor].sample}
			enemys.each do |d|
				id = d[:monsterId]
				atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
				cd,duration = d[:CD],d[:duration]
				characteristic = d[:characteristic]
				@enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
				@enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
				x += 120
			end
		else
			length = FLOOR_DATA::FLOOR[@id][:waves][@floor].length
			x,y = 60*(4-length),20
			
			FLOOR_DATA::FLOOR[@id][:waves][@floor].each do |d|
				id = d[:monsterId]
				atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
				cd,duration = d[:CD],d[:duration]
				characteristic = d[:characteristic]
				@enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
				@enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
				x += 120
			end
		end
	end
end

