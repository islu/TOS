class Image
  def initialize(img,x,y,z)
		@img = Gosu::Image.new(img)
		@w,@h = @img.width,@img.height
		@x,@y,@z = x,y,z
  end
	def draw(sx=1, sy=1, color=0xff_ffffff)
		@img.draw(@x,@y,@z,sx,sy,color)
	end
		
	def set(x,y)
		@x,@y = x,y
	end
	def pos
		return @x,@y
	end
	
	def x; @x; end
	def y; @y; end
	def w; @w; end
	def h; @h; end
end

class Stone < Image
	def initialize(x,y)
		@attrlist = ["_w","_f","_e","_l","_d","_h"]
		@attr = @attrlist.sample
		@en = ""
		@type = ""
		super "image/stone#{@attr}.png",x,y,2
	end
	
	def attr; @attr; end
	def en; @en; end
	# def can_delete?
		# @type != "_fr"
	# end
	def deleted?; @attr == "_n"; end
	def water?; @attr == "_w"; end
	def fire?;  @attr == "_f"; end
	def eath?;  @attr == "_e"; end
	def light?; @attr == "_l"; end
	def dark?;  @attr == "_d"; end
	def heart?; @attr == "_h"; end
	def enchante?; !@en == "_en"; end
	
	def drop; @y += 8; end
	
	def new(attr=@attrlist.sample,en="",type="")
		@attr = attr
		@en = en
		@type = type
		update_img
	end
	
	def drag(x,y); @x,@y = x-@w/2,y-@h/2; end
	def update_img; @img = Gosu::Image.new("image/stone#{@attr}#{@en}#{@type}.png"); end
	
	def nostone; @attr = "_n"; @en = ""; @type = "" end
	
	def transform_to_w; @attr = "_w"; end
	def transform_to_f; @attr = "_f"; end
	def transform_to_e; @attr = "_e"; end
	def transform_to_l; @attr = "_l"; end
	def transform_to_d; @attr = "_d"; end
	def transform_to_h; @attr = "_h"; end
	def transform_to_random; @attr = @attrlist.sample; end
	#def transform_to_random_for(attrList); @attr = attrList.sample; end
	
	def enchante;   @en = "_en"; end
	def non_enchante; @en = ""; end
	
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