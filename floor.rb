class Enemy < Image
	def initialize(x,y,id,atk,hp,dfs,cd,duration,characteristic)
		@id = id
		@atk,@hp,@dfs, = atk,hp,dfs
		@cd,@duration = cd,duration
		@characteristic = characteristic
		@font = Gosu::Font.new(25)
		super "image/monster/#{@id}n.png",x,y,1
	end
	def draw(sx=0.5, sy=0.5, color=0xff_ffffff)
		@img.draw(@x,@y,@z,sx,sy,color)
		@font.draw_text("#{@cd}",@x+@w/4+30,@y+@h/4,1,1.0,1.0,Gosu::Color::YELLOW)
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
	def update
		@enemys.delete_if(&:die?)
		cd_countdown
		wave_claer? and next_wave
	end
	def draw_enemys
		@enemys.each(&:draw)
	end
	def draw_wave
		@font.draw_text("wave: #{@floor+1}",0,0,1,1.0,1.0,Gosu::Color::YELLOW)
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

module FLOOR_DATA
  FLOOR = {
		"遠洋的王者" => {
			name: "符靈之主 地獄級",
			setting: ["x", "x", "random1", "x", "x"],
			waves: [
				[{monsterId: 444, atk: 6877, CD: 1, duration: 1, hp: 18994, dfs: 10, characteristic: 100},{monsterId: 443, atk: 6041, CD: 1, duration: 1, hp: 39708, dfs: 40, characteristic: 150},{monsterId: 446, atk: 6221, CD: 2, duration: 2, hp: 29014, dfs: 30, characteristic: 50},{monsterId: 447, atk: 6356, CD: 2, duration: 2, hp: 61953, dfs: 60, characteristic: 123}],
				[{monsterId: 137, atk: 4727, CD: 2, duration: 2, hp: 233936, dfs: 40, characteristic: 30},{monsterId: 140, atk: 4954, CD: 2, duration: 2, hp: 234159, dfs: 39, characteristic: 32},{monsterId: 131, atk: 4725, CD: 2, duration: 2, hp: 233823, dfs: 40, characteristic: 134}],
				[{monsterId: 133, atk: 6270, CD: 1, duration: 1, hp: 640735, dfs: 606, characteristic: 1},{monsterId: 136, atk: 6690, CD: 1, duration: 1, hp: 629985, dfs: 594, characteristic: 1},{monsterId: 139, atk: 6273, CD: 1, duration: 1, hp: 643423, dfs: 600, characteristic: 1},{monsterId: 142, atk: 6687, CD: 1, duration: 1, hp: 646611, dfs: 579, characteristic: 1},{monsterId: 145, atk: 6690, CD: 1, duration: 1, hp: 640735, dfs: 582, characteristic: 1}],
				[{monsterId: 439, atk: 10644, CD: 2, duration: 2, hp: 473500, dfs: 240, characteristic: 309},{monsterId: 442, atk: 9680, CD: 1, duration: 1, hp: 462800, dfs: 5250, characteristic: 147}],
				[{monsterId: 448, atk: 10520, CD: 1, duration: 1, hp: 2058000, dfs: 9800, characteristic: 75}]
			]
		},
		2 => {
		name: "日蝕之子 地獄級",
		setting: ["random2", "random3", "x", "x", "random3", "x"],
		waves: [
			[{monsterId: 106, atk: 6831, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0},{monsterId: 108, atk: 7624, CD: 2, duration: 2, hp: 12, dfs: 20, characteristic: 0},{monsterId: 110, atk: 7063, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0}],
			[{monsterId: 106, atk: 6831, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0},{monsterId: 108, atk: 7624, CD: 2, duration: 2, hp: 12, dfs: 20, characteristic: 0},{monsterId: 110, atk: 7063, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0}],
			[{monsterId: 113, atk: 8314, CD: 2, duration: 2, hp: 8, dfs: 39, characteristic: 57},{monsterId: 115, atk: 8579, CD: 2, duration: 2, hp: 9, dfs: 39, characteristic: 57}],
		]},
 }

end