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
	attr_reader :attr
	def initialize(x,y)
		@attrlist = ["_w","_f","_e","_l","_d","_h"]
		@attr = @attrlist.sample
		@en = ""
		@type = ""
		super "image/stone#{@attr}.png",x,y,1
	end
	
	def drag(x,y)
		@x,@y = x-@w/2,y-@h/2
	end
	def set(x,y)
		@x,@y = x,y
	end
	
	# 轉換符石後更新圖片 (每次轉換呼叫一次即可)
	def update_img; @img = Gosu::Image.new("image/stone#{@attr}#{@en}#{@type}.png"); end
	# 刪除符石
	def nostone; @attr = "_n"; @en = ""; @type = "" end
	# 轉換屬性符石
	def transform_to_w; @attr = "_w"; end
	def transform_to_f; @attr = "_f"; end
	def transform_to_e; @attr = "_e"; end
	def transform_to_l; @attr = "_l"; end
	def transform_to_d; @attr = "_d"; end
	def transform_to_h; @attr = "_h"; end
	def transform_to_random; @attr = @attrlist.sample; end
	# 轉換強化符石
	def strong;   @en = "_en"; end
	def unstrong; @en = ""; end
	# 轉換種族符石
	def race_human;    @type = "_h"; end
	def race_god;      @type = "_g"; end
	def race_demon;    @type = "_de"; end
	def race_dragon;   @type = "_dr"; end
	def race_beast;    @type = "_b"; end
	def race_elf;      @type = "_e"; end
	def race_mechanic; @type = "_m"; end
	
	#def frozen; @type = "_fr"; end
	#def locking; @type = "_lk"; end
end