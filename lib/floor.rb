class Enemy < Image

    # Create an enemy object
    #
    # @param [Integer] x X coodinate of the enemy
    # @param [Integer] y Y coodinate of the enemy
    # @param [Integer] id ID of the enemy
    # @param [Integer] atk Attack of the enemy
    # @param [Integer] hp HP of the enemy
    # @param [Integer] dfs Defense of the enemy
    # @param [Integer] cd CD of the enemy
    # @param [Integer] duration Duration of the enemy's skill
    # @param [Integer] characteristic Characteristic of the enemy
    def initialize(x, y, id, atk, hp, dfs, cd, duration, characteristic)
        @sx, @sy = 50, 350
        @font = Gosu::Font.new(25)

        @id=id
        @atk, @hp, @dfs, = atk, hp, dfs
        @cd, @duration = cd, duration
        @characteristic = characteristic
        @attr = DATA::MONSTER[@id][:attr]
        @description = ENEMY::SKILL[@characteristic][:description]
        @maxHp = hp.to_f

        super "image/monster/#{@id}n.png",x,y,1

        line_feed
    end

    # Draw the enemy object
    #
    # @param [Number] sx X scale of the enemy
    # @param [Number] sy Y scale of the enemy
    # @param [Color, Integer] color Color of the enemy
    def draw(sx=0.5, sy=0.5, color=0xff_ffffff)
        @img.draw(@x,@y,@z,sx,sy,color)
        # Draw CD of the enemy's skill
        if @h == 512
            @font.draw_text("#{@cd}", @x+@w/4+65, @y+@h/4, 3, 1.0, 1.0, Gosu::Color::YELLOW)
        elsif @h == 256
            @font.draw_text("#{@cd}", @x+@w/4+35, @y+@h/4, 3, 1.0, 1.0, Gosu::Color::YELLOW)
        end
        # Draw HP of the enemy
        @font.draw_text("#{(@hp/@maxHp*100).ceil}%", @x+@w/4-25, @y+@h/2, 1, 1.0, 1.0, atk_font_color(attr))
    end

    # Check if the mouse is hovering over the enemy
    #
    # @param [Number] mx X coordinate of the mouse
    # @param [Number] my Y coordinate of the mouse
    # @return [Boolean] true if the mouse is hovering over the enemy
    def hover?(mx, my)
        @x<=mx && mx<=@x+@w/2 && @y+@h/2>my && my>@y
    end

    # Draw the enemy's skill when the mouse is hovering over it
    #
    # @param [Number] mx X coordinate of the mouse
    # @param [Number] my Y coordinate of the mouse
    def draw_skill(mx, my)
        # Only draw the skill if the mouse is hovering over the enemy
        if hover?(mx,my)
            # Draw a gray background for the skill
            Gosu.draw_quad(@sx-25,@sy-25,Gosu::Color::GRAY,@sx+400,@sy-25,Gosu::Color::GRAY,@sx+400,@sy+200,Gosu::Color::BLACK,@sx-25,@sy+200,Gosu::Color::BLACK,3)
            # Draw the name and description of the enemy's skill
            @font.draw_markup("#{DATA::MONSTER[@id][:name]} <c=00ff00>#{ENEMY::SKILL[@characteristic][:name]}</c>",@sx,@sy,3,1.0,1.0,Gosu::Color::YELLOW)
            @font.draw_text("#{@description}",@sx,@sy+50,3,1.0,1.0,Gosu::Color::YELLOW)
        end
    end

    # Check if the enemy is dead
    #
    # @return [Boolean] true if the enemy is dead
    def die?
        # The enemy is dead if its HP is 0 or less
        @hp <= 0
    end

    # Take damage from the player
    #
    # @param damage [Integer] the damage taken by the enemy
    def take_damage(damage)
        # If the enemy has defense, subtract the defense from the damage
        # Otherwise, subtract the damage from the enemy's HP
        if damage <= @dfs
            # Enemy has defense, so only subtract 1 from the HP
            @hp -= 1
        else
            # Enemy does not have defense, so subtract the full damage
            @hp -= (damage-@dfs)
        end
    end

    # Decrement the enemy's cooldown
    #
    # The enemy's cooldown will be decremented by 1 if it is not already 0
    def dec
        # Only decrement the cooldown if it is not already 0
        @cd -= 1 if @cd != 0
    end

    # Check if the enemy can attack
    #
    # @return [Boolean] true if the enemy can attack
    def can_attack?
        # The enemy can attack if its cooldown is 0
        @cd == 0
    end

    # Reset the enemy's cooldown
    #
    # @return [void]
    def cd_reset
        # Reset the cooldown to the duration
        @cd = @duration
    end

    # Return the enemy's attack
    #
    # @return [Integer] the enemy's attack
    def damage
        # Simply return the enemy's attack
        @atk
    end

    # Return the enemy's characteristic
    #
    # @return [Integer] the enemy's characteristic
    def characteristic
        # Simply return the enemy's characteristic
        @characteristic
    end

    # Return the enemy's attribute
    #
    # @return [String] the enemy's attribute
    def attr
        @attr
    end

    private

    # Modify the enemy's description to wrap it to a new line when it hits
    # a certain length
    #
    # @param maxlen [Integer] the max length of each line
    # @return [void]
    def line_feed(maxlen=20)
        # Keep track of how many characters have been processed so far
        counter = 0
        # The new description with line breaks
        str = ""
        # Iterate over each character in the description
        @description.each_char do |c|
            # Increment the counter
            counter += 1
            # Add the character to the string
            str += c
            # If we have hit the max length, add a newline char and reset the counter
            if counter == maxlen
                str += "\n"
                counter = 0
            end
        end
        # Replace the description with the new one with line breaks
        @description = str
    end

    # Get the color of the font for the enemy's attack
    #
    # @param attr [String] The attribute of the enemy
    # @return [Gosu::Color] the color of the font
    def atk_font_color(attr)
        case attr
        when "_w" # Water
            Gosu::Color::AQUA
        when "_f" # Fire
            Gosu::Color::RED
        when "_e" # Earth
            Gosu::Color::GREEN
        when "_l" # Light
            Gosu::Color::YELLOW
        when "_d" # Dark
            Gosu::Color::FUCHSIA
        else # Heart
            Gosu::Color::WHITE;
        end
    end

end

class Floor
    # Constructor
    #
    # @param id [Integer] The id of the floor
    def initialize(id)
        # The id of the floor
        @id = id
        # The total number of waves in the floor
        @waves = FLOOR_DATA::FLOOR[@id][:waves].length
        # The current turn of the floor
        @turn = 0
        # The array of enemies in the floor
        @enemys = []
        # The current floor number
        @floor = 0
        # The font used to draw the text
        @font = Gosu::Font.new(25)
        # Generate the enemies for the first wave
        generate_enemys
    end

    # Check if all waves are cleared
    #
    # @return [Boolean] If all waves are cleared
    def all_clear?
        # If the current floor number is equal to the total number of waves
        # then all waves are cleared
        @floor == @waves
    end

    # Check if the current wave is cleared
    #
    # @return [Boolean] If the current wave is cleared
    def wave_claer?
        # If the array of enemies is empty, then the current wave is cleared
        @enemys.empty?
    end

    # Move to the next wave
    #
    # @return [Boolean] If the next wave is the last wave
    def next_wave
        # Increment the current floor number
        @floor += 1
        # Generate the enemies for the next wave if the current wave is not the last wave
        !all_clear? and generate_enemys
    end

    # Take damage from the player
    #
    # @param damages [Array<Integer>] The damage taken by the enemies
    def take_damage(damages)
        # Print the damage taken
        print "damages: "
        p damages
        targetId = 0
        damages.each do |d|
            # If all enemies are dead, then the first enemy will take the damage
            if targetId == @enemys.length
                @enemys[0].take_damage(d)
            else
                # Take the damage and increment the targetId if the enemy is dead
                @enemys[targetId].take_damage(d)
                targetId += 1 if @enemys[targetId].die?
            end
        end
    end

    # Calculate the total damage that the enemies will take
    #
    # @return [Array<Integer>] The total damage that the enemies will take
    def damage
        # Initialize the result array
        result = []
        # Iterate over each enemy
        @enemys.each do |e|
            # If the enemy is not dead and can attack, then add the damage to the result array
            # and reset the cooldown
            if e.can_attack?
                result << e.damage
                e.cd_reset
            end
        end
        # Return the result array
        return result
    end

    # Count down the cooldown of each enemy
    #
    # @return [nil] Returns nothing
    def cd_countdown
        # Iterate over each enemy
        @enemys.each do |e|
            # Decrement the cooldown of the enemy
            e.dec
        end
    end

    # Return the array of enemies in the floor
    #
    # @return [Array<Enemy>] The array of enemies in the floor
    def enemys
        @enemys
    end

    # Update the state of the floor
    #
    # @return [nil] Returns nothing
    def update
        # Delete all enemies that are dead
        @enemys.delete_if(&:die?)
        # Count down the cooldown of each enemy
        cd_countdown
        # If the current wave is cleared, then move to the next wave
        wave_claer? and next_wave
    end

    # Draw all the enemies in the floor
    #
    # @return [nil] Returns nothing
    def draw_enemys
        # Iterate over each enemy and draw it
        @enemys.each(&:draw)
    end

    # Draw the current wave number and the name of the floor
    #
    # @return [nil] Returns nothing
    def draw_wave
        # The text to be drawn
        text = "wave: #{@floor+1} #{FLOOR_DATA::FLOOR[@id][:name]}"
        # Draw the text
        @font.draw_text(text,0,0,1,1.0,1.0,Gosu::Color::YELLOW)
    end

    # Draw the skills of all the enemies in the floor if the mouse is hovering over an enemy
    #
    # @param [Integer] mx The x coordinate of the mouse
    # @param [Integer] my The y coordinate of the mouse
    # @return [nil] Returns nothing
    def draw_skills(mx,my)
        # Iterate over each enemy and draw its skill if the mouse is hovering over the enemy
        @enemys.each {|e| e.draw_skill(mx,my)}
    end

    private

    # Generate the enemies for the floor
    #
    # @return [void] Returns nothing
    def generate_enemys
        # The type of enemies to generate
        case FLOOR_DATA::FLOOR[@id][:setting][@floor]
        # Generate two random enemies
        when "random1"
            x,y = 180,20
            enemys = []
            enemys << FLOOR_DATA::FLOOR[@id][:waves][@floor].sample
            enemys.each do |d|
                id = d[:monsterId]
                atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
                cd,duration = d[:CD],d[:duration]
                characteristic = d[:characteristic]
                # Create a new enemy with the given parameters and add it to the array
                @enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
                # Set the y coordinate of the enemy to -80 if its height is 512
                @enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
                # Increment the x coordinate
                x += 120
            end
        # Generate two random enemies
        when "random2"
            x,y = 120,20
            enemys = []
            2.times {enemys << FLOOR_DATA::FLOOR[@id][:waves][@floor].sample}
            enemys.each do |d|
                id = d[:monsterId]
                atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
                cd,duration = d[:CD],d[:duration]
                characteristic = d[:characteristic]
                # Create a new enemy with the given parameters and add it to the array
                @enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
                # Set the y coordinate of the enemy to -80 if its height is 512
                @enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
                # Increment the x coordinate
                x += 120
            end
        # Generate three random enemies
        when "random3"
            x,y = 40,20
            enemys = []
            3.times {enemys << FLOOR_DATA::FLOOR[@id][:waves][@floor].sample}
            enemys.each do |d|
                id = d[:monsterId]
                atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
                cd,duration = d[:CD],d[:duration]
                characteristic = d[:characteristic]
                # Create a new enemy with the given parameters and add it to the array
                @enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
                # Set the y coordinate of the enemy to -80 if its height is 512
                @enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
                # Increment the x coordinate
                x += 120
            end
        # Generate the enemies specified in the config
        else
            # The length of the array of enemies
            length = FLOOR_DATA::FLOOR[@id][:waves][@floor].length
            # The x coordinate of the first enemy
            x,y = 60*(4-length),20

            FLOOR_DATA::FLOOR[@id][:waves][@floor].each do |d|
                id = d[:monsterId]
                atk,hp,dfs, = d[:atk],d[:hp],d[:dfs]
                cd,duration = d[:CD],d[:duration]
                characteristic = d[:characteristic]
                # Create a new enemy with the given parameters and add it to the array
                @enemys << Enemy.new(x,y,id,atk,hp,dfs,cd,duration,characteristic)
                # Set the y coordinate of the enemy to -80 if its height is 512
                @enemys[-1].set(x-50,-80) if @enemys[-1].h == 512
                # Increment the x coordinate
                x += 120
            end
        end
    end
end

