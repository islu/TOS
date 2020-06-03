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
		generate_enemys
	end

	def clear?
		@floor == @waves
	end
	def next_wave
		@floor += 1
	end
	def damage
		result = []
		@enemys.each {|e|
			if e.can_attack?
				result << e.damage
				e.cd_reset
			end
		}
		puts "floor#damage -> enemys damage stack #{result}"
		return result
	end
	def cd_countdown
		@enemys.each(&:dec)
	end
	def update
		@enemys.delete_if(&:die?)
	end
	def draw_enemys
		@enemys.each(&:draw)
	end
	private
	def generate_enemys
		case FLOOR_DATA::FLOOR[@id][:setting][@floor]
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
				x += 120
			end
		when "all"
			x,y = 40,20
			FLOOR_DATA::FLOOR[@id][:waves][@floor].each do |d|
				id = d[:monsterId]
				atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
				cd,duration = d[:CD],d[:duration]
				characteristic = d[:characteristic]
				@enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
				x += 120
			end
		end
	end
end

module FLOOR_DATA
  FLOOR = {
		2 => {
		name: "日蝕之子 地獄級",
		setting: ["random2", "random3", "all", "all", "random3", "all"],
		waves: [
			[{monsterId: 106, atk: 6831, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0},{monsterId: 108, atk: 7624, CD: 2, duration: 2, hp: 12, dfs: 20, characteristic: 0},{monsterId: 110, atk: 7063, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0}],
			[{monsterId: 106, atk: 6831, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0},{monsterId: 108, atk: 7624, CD: 2, duration: 2, hp: 12, dfs: 20, characteristic: 0},{monsterId: 110, atk: 7063, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0}],
		]},
 }

end