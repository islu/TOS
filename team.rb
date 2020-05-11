module DATA
	MONSTER = {
		1239 => {attr: '_f', race: '_g', star: 6, lv: 99, hp: 3209, atk: 1651, re: 314, AS: {name: '三原靈陣 ‧ 血燄', charge: 'CD', num: 8, description: '所有符石隨機轉化為水、火、木及心符石，同時火符石出現率上升，並將火符石以火強化符石代替'}, },
	}
end
module AS
	def break_stone(stones)
		stones.each
	end
end

class Monster < Image
	include AS
	def initialize(id,order)
		@id = id
		@order = order
		@iconsize = 80
		@ybias = 210
		super "image/#{@id}.png",@order*@iconsize,@ybias,1
		@font = Gosu::Font.new(25)
		@sx,@sy = 600,100
	end
	def draw
		@img.draw(@x,@y,@z,0.8,0.8)
	end
	def draw_skills
		@font.draw_text("#{DATA::MONSTER[@id][:AS][:name]}",@sx,@sy,@z,1.0,1.0,Gosu::Color::WHITE)
		@font.draw_text("#{DATA::MONSTER[@id][:AS][:description]}",@sx,@sy+25,@z,1.0,1.0,Gosu::Color::WHITE)
	end
	def id; @id; end
end

class Team
	def initialize(ids)
		@monsters = []
		@iconsize = 80
		@ybias = 210
		init(ids)
	end
	def monster?(mx,my)
		!(my<@ybias || my>@ybias+@iconsize || mx<0 || mx>@iconsize*@monsters.length)
	end
	def index(mx,my)
		(mx/@iconsize).floor if monster?(mx,my)
	end
	def get_skill_data
		
	end
	
	def draw_skills(i)
		@monsters[i].draw_skills if !i.nil?
	end
	def draw
		@monsters.each {|m| m.draw}
	end

	private
	def init(ids)
		ids.each_index {|i| @monsters<<Monster.new(ids[i],i)}
	end
end