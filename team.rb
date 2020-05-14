module DATA
	MONSTER = {
		1239 => {attr: '_f', race: '_g', star: 6, lv: 99, hp: 3209, atk: 1651, re: 314},
	}
	SKILL = {
		1239 => {name: '三原靈陣 ‧ 血燄', charge: 'CD', num: 8, description: "所有符石隨機轉化為水、火、木及心符石，\n同時火符石出現率上升，\n並將火符石以火強化符石代替"},
	}
end

class Monster < Image
	include DATA
	def initialize(id,order)
		@id = id
		@order = order
		@iconsize = 80
		@ybias = 210
		super "image/#{@id}.png",@order*@iconsize,@ybias,1
		@font = Gosu::Font.new(25)
		@sx,@sy = 50,350
		
		@num = DATA::SKILL[@id][:num]
	end
		
	def draw_icon
		@img.draw(@x,@y,@z,0.8,0.8)
	end
	def draw_skill
		Gosu.draw_quad(@sx-25,@sy-25,Gosu::Color::GRAY,@sx+400,@sy-25,Gosu::Color::GRAY,@sx+400,@sy+200,Gosu::Color::FUCHSIA,@sx-25,@sy+200,Gosu::Color::FUCHSIA,3)
		@font.draw_text("#{DATA::SKILL[@id][:name]}",@sx,@sy,3,1.0,1.0,Gosu::Color::YELLOW)
		@font.draw_text("#{DATA::SKILL[@id][:description]}",@sx,@sy+50,3,1.0,1.0,Gosu::Color::YELLOW)
	end
	def id; @id; end
end

class Team
	def initialize(ids)
		@monsters = []
		@iconsize = 80
		@ybias = 210
		
		@currLife,@maxLife = 0,0
		init(ids)
		init_life
	end
	def id(i)
		@monsters[i].id
	end
	
	def monster?(mx,my)
		!(my<@ybias || my>@ybias+@iconsize || mx<0 || mx>@iconsize*@monsters.length)
	end
	def index(mx,my)
		(mx/@iconsize).floor if monster?(mx,my)
	end
	
	def draw_skills(i)
		@monsters[i].draw_skill if @monsters.at(i) != nil
	end
	def draw_icons
		@monsters.each {|m| m.draw_icon}
	end
	
	def currLife; @currLife; end
	def maxLife; @maxLife; end

	private
	def init(ids)
		ids.each_index {|i| @monsters<<Monster.new(ids[i],i)}
	end
	def init_life
		@monsters.each{|monster| @maxLife += DATA::MONSTER[monster.id][:hp]}
		@currLife = @maxLife
	end
end