class Image
    # Create a new Image object with the specified image file, x, y and z coordinates.
    #
    # @param img [String] the path to the image file
    # @param x [Integer] the x coordinate
    # @param y [Integer] the y coordinate
    # @param z [Integer] the z coordinate (the "layer" of the image)
    def initialize(img, x, y, z)
        # Load the image file into a Gosu::Image object
        @img = Gosu::Image.new(img)

        # Store the width and height of the image
        @w, @h = @img.width, @img.height

        # Store the x, y and z coordinates
        @x, @y, @z = x, y, z
    end

    # Draw the image at the current position and size.
    #
    # @param sx [Float] the x scale of the image (default: 1)
    # @param sy [Float] the y scale of the image (default: 1)
    # @param color [Integer] the color of the image (default: white)
    def draw(sx=1 , sy=1, color=0xff_ffffff)
        # Draw the image with the specified scale and color
        @img.draw(@x, @y, @z, sx, sy, color)
    end

    # Set the x and y coordinates of the image.
    #
    # @param x [Integer] the new x coordinate
    # @param y [Integer] the new y coordinate
    def set(x, y)
        # Store the new x and y coordinates
        @x, @y = x, y
    end

    # Get the current position of the image as an array [x, y].
    #
    # @return [Array] the current position of the image
    def pos
        # Return the current position as an array
        return [@x, @y]
    end

    # Check if the mouse is hovering over the image.
    #
    # @param mx [Integer] the x coordinate of the mouse
    # @param my [Integer] the y coordinate of the mouse
    # @return [Boolean] true if the mouse is hovering over the image
    def hover?(mx, my)
        # Check if the mouse is within the bounds of the image
        @x<=mx && mx<=@x+@w && @y+@h>my && my>@y
    end


    # Getters

    def x; @x; end
    def y; @y; end
    def w; @w; end
    def h; @h; end
end

class Stone < Image
    # Initializes a new Stone object with the given x and y coordinates.
    #
    # @param x [Integer] the x coordinate
    # @param y [Integer] the y coordinate
    def initialize(x, y)
        # List of possible attributes for a stone
        @attrlist = ["_w","_f","_e","_l","_d","_h"]
        # The attribute of the stone
        @attr = @attrlist.sample
        # The enchantment of the stone
        @en = ""
        # The type of stone
        @type = ""
        # Create the image
        super "image/stone#{@attr}.png", x, y, 2
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
    def attr?(attr); @attr == attr; end
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
    def transform_to_x(attr); @attr = attr; end
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