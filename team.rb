module DATA
	MONSTER = {
		1239 => {attr: '_f', race: '_g', star: 6, lv: 99, hp: 3209, atk: 1651, re: 314},
	}
	AS = {
		1239 => {name: '三原靈陣 ‧ 血燄', charge: 'CD', num: 8, description: "所有符石隨機轉化為水、火、木及心符石，同時火符石出現率上升，並將火符石以火強化符石代替"},
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
		
		@num = DATA::AS[@id][:num]
		@description = DATA::AS[@id][:description]
		@currAtk = 0.0
		
		line_feed
	end
	
	def dec_num
		@num -= 1
		@num = 0 if @num < 0
	end
	def can_active?; @num == 0; end
	def active; @num = DATA::AS[@id][:num]; end
	
	def draw_icon
		if can_active?
			@img.draw(@x,@y-10,@z,0.8,0.8)
		else	
			@img.draw(@x,@y,@z,0.8,0.8)
		end
	end
	def draw_skill
		Gosu.draw_quad(@sx-25,@sy-25,Gosu::Color::GRAY,@sx+400,@sy-25,Gosu::Color::GRAY,@sx+400,@sy+200,Gosu::Color::FUCHSIA,@sx-25,@sy+200,Gosu::Color::FUCHSIA,3)
		@font.draw_text("#{DATA::AS[@id][:name]}  #{@num}/#{DATA::AS[@id][:num]}",@sx,@sy,3,1.0,1.0,Gosu::Color::YELLOW)
		@font.draw_text("#{@description}",@sx,@sy+50,3,1.0,1.0,Gosu::Color::YELLOW)
	end
	def draw_atk
		@font.draw_text("#{@currAtk}",@x+5,@y+25,3,1.0,1.0,Gosu::Color::RED)
	end
	def update_atk(atk)
		@currAtk = atk
	end

	def attr; DATA::MONSTER[@id][:attr]; end
	def race; DATA::MONSTER[@id][:race]; end
	def hp; DATA::MONSTER[@id][:hp]; end
	def atk; DATA::MONSTER[@id][:atk]; end
	def re; DATA::MONSTER[@id][:re]; end
	def id; @id; end
	def num; @num; end

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
	def monsters; @monsters; end
	def first_leader; @monsters.first; end
	def second_leader; @monsters.last; end
	
	def monster?(mx,my)
		!(my<@ybias || my>@ybias+@iconsize || mx<0 || mx>@iconsize*@monsters.length)
	end
	def index(mx,my)
		(mx/@iconsize).floor if monster?(mx,my)
	end
	
	def draw_skill(i)
		@monsters[i].draw_skill if @monsters.at(i) != nil
	end
	def draw_icon
		@monsters.each {|monster| monster.draw_icon}
	end
	def draw_atk
		@monsters.each {|m| m.draw_atk}
	end
	
	def charge
		@monsters.each {|monster| monster.dec_num}
	end
	def can_active?(i)
		@monsters[i].can_active? if @monsters.at(i) != nil
	end
	def active(i)
		@monsters[i].active if @monsters.at(i) != nil
	end	
	
	def currLife; @currLife; end
	def maxLife; @maxLife; end

	private
	def init(ids)
		ids.each_index {|i| @monsters << Monster.new(ids[i],i)}
	end
	def init_life
		@monsters.each {|monster| @maxLife += monster.hp}
		@currLife = @maxLife
	end
end