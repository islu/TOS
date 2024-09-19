class Monster < Image
    # @param id [Integer] the id of the monster
    # @param order [Integer] the order of the monster in the team
    def initialize(id,order)
        @id = id
        @order = order
        @iconsize = 80
        @ybias = 210
        super "image/monster_icon/#{@id}.png",@order*@iconsize,@ybias,1
        @font = Gosu::Font.new(25)
        @sx,@sy = 50,350

        # The attribute of the monster
        @atkAttr = DATA::MONSTER[@id][:attr]
        # The number of remaining active skill times
        @num = DATA::AS[@id][:num]
        # The description of the active skill
        @description = DATA::AS[@id][:description]

        # The current attack of the monster
        @currAtk = 0.0
        # The current recovery of the monster
        @currRe = 0.0

        line_feed
    end

    # Decrease the number of remaining active skill times
    # @return [void]
    def dec_num
        @num -= 1
        @num = 0 if @num < 0
    end

    # Return true if the active skill can be used
    #
    # @return [Boolean] whether the active skill can be used
    def can_active?
        @num == 0
    end

    # Increase the number of remaining active skill times
    #
    # @return [void]
    def active
        @num = DATA::AS[@id][:num]
    end

    # Draw the monster icon
    #
    # If the skill is available, the icon will be drawn with a small offset
    # to indicate that it is ready to use.
    #
    # @return [void]
    def draw_icon
        if can_active?
            @img.draw(@x,@y-10,@z,0.8,0.8)
        else
            @img.draw(@x,@y,@z,0.8,0.8)
        end
    end

    # Draw the active skill
    #
    # @return [void]
    def draw_skill
        # Draw the background box
        Gosu.draw_quad(@sx-25,@sy-25,Gosu::Color::GRAY,@sx+400,@sy-25,Gosu::Color::GRAY,@sx+400,@sy+200,Gosu::Color::FUCHSIA,@sx-25,@sy+200,Gosu::Color::FUCHSIA,3)

        # Draw the skill name
        @font.draw_markup("#{DATA::AS[@id][:name]}  <c=00ff00>#{@num}/#{DATA::AS[@id][:num]}</c>",@sx,@sy,3,1.0,1.0,Gosu::Color::YELLOW)

        # Draw the skill description
        @font.draw_text("#{@description}",@sx,@sy+50,3,1.0,1.0,Gosu::Color::YELLOW)
    end

    # Draw the attack value of the monster
    #
    # @return [void]
    def draw_atk
        # Only draw the attack value if it is not zero
        if @currAtk != 0
            # Get the color of the text based on the attribute of the monster
            color = atk_font_color(atkAttr)
            # Draw the attack value
            @font.draw_text("#{@currAtk}",@x+5,@y+25,3,1.0,1.0,color)
        end
    end

    # Update the current attack value of the monster
    #
    # @param atk [Integer] The current attack value of the monster
    # @return [void]
    def update_atk(atk)
        @currAtk = atk
    end

    # Update the current recovery value of the monster
    #
    # @param re [Integer] The current recovery value of the monster
    # @return [void]
    def update_re(re)
        @currRe = re
    end
    # Reset the current attack and recovery value of the monster
    #
    # @return [void]

    def reset
        # Reset the current attack and recovery value to 0
        @currAtk,@currRe = 0,0
    end

    # Get the attribute of the monster
    #
    # @return [String] the attribute of the monster
    def attr
        DATA::MONSTER[@id][:attr]
    end

    # Get the attribute of the monster
    #
    # @return [String] the attribute of the monster
    def atkAttr
        @atkAttr
    end

    # Get the race of the monster
    #
    # @return [String] The race of the monster
    def race
        DATA::MONSTER[@id][:race]
    end

    # Get the HP of the monster
    #
    # @return [Integer] The HP of the monster
    def hp
        DATA::MONSTER[@id][:hp]
    end

    # Get the attack value of the monster
    #
    # @return [Integer] the attack value of the monster
    def atk
        DATA::MONSTER[@id][:atk]
    end

    # Get the recovery value of the monster
    #
    # @return [Integer] the recovery value of the monster
    def re
        DATA::MONSTER[@id][:re]
    end

    # Get the current recovery value of the monster
    #
    # @return [Integer] the current recovery value of the monster
    def currRe
        @currRe
    end

    # Get the current attack value of the monster
    #
    # @return [Integer] the current attack value of the monster
    def currAtk
        @currAtk
    end

    # Get the ID of the monster
    #
    # @return [Integer] The ID of the monster
    def id
        @id
    end

    # The number of remaining active skill times
    #
    # @return [Integer] The number of remaining active skill times
    def num
        @num
    end

    private
    # Modify the description of the monster to wrap it to a new line when it hits
    # a certain length
    #
    # @param maxlen [Integer] the max length of each line
    # @return [void]
    def line_feed(maxlen=20)
        # Count the number of characters that have been processed so far
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

    # Get the color of the font for the attack
    #
    # @param attr [String] The attribute of the monster
    # @return [Gosu::Color] the color of the font
    def atk_font_color(attr)
        # Use the proper color for the attribute
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

class Team
    # Initialize the team with the given monster ids
    #
    # @param ids [Array<Integer>] the ids of the monsters
    def initialize(ids)
        @monsters = []
        # The size of the monster icons
        @iconsize = 80
        # The y bias of the monster icons
        @ybias = 210
        # The temporary time for showing the damage
        @temptime = 0
        # The speed of the damage
        @damagespeed = 450

        # The current life and max life of the team
        @currLife,@maxLife = 0,0

        # Initialize the monsters and the life
        init(ids)
        init_life
    end

    # Return the id of the monster at the given index
    #
    # @param i [Integer] the index of the monster
    # @return [Integer] the id of the monster
    def id(i)
        @monsters[i].id
    end

    # Return the array of Monster objects
    #
    # @return [Array<Monster>] The array of Monster objects
    def monsters
        @monsters
    end

    # Return the first monster of the team
    #
    # @return [Monster] The first monster of the team
    def first_leader
        @monsters.first
    end

    # Return the second monster of the team
    #
    # @return [Monster] The second monster of the team
    def second_leader
        @monsters.last
    end

    # Check if the mouse is hovering over a monster icon
    #
    # @param mx [Integer] The x position of the mouse
    # @param my [Integer] The y position of the mouse
    # @return [Boolean] Whether the mouse is hovering over a monster icon
    def monster?(mx,my)
        # Check if the y position of the mouse is within the range of the monster icon
        # and if the x position of the mouse is within the range of the monster icon
        !(my<@ybias || my>@ybias+@iconsize || mx<0 || mx>@iconsize*@monsters.length)
    end

    # Return the index of the monster that the mouse is hovering over
    #
    # @param mx [Integer] The x position of the mouse
    # @param my [Integer] The y position of the mouse
    # @return [Integer] The index of the monster
    def index(mx,my)
        # Calculate the index of the monster using the mouse position
        (mx/@iconsize).floor if monster?(mx,my)
    end

    # Draw the skill of the monster at the given index
    #
    # @param i [Integer] The index of the monster
    # @return [void]
    def draw_skill(i)
        # Check if the index is within the bounds of the array and if the monster at the index is not nil
        # Then draw the skill of the monster
        @monsters[i].draw_skill if @monsters.at(i) != nil
    end

    # Draw the icon of each monster in the team
    #
    # @return [void]
    def draw_icon
        # Iterate over each monster in the team
        # and draw its icon
        @monsters.each {|m| m.draw_icon}
    end

    # Draw the attack value of each monster in the team
    #
    # @return [void]
    def draw_atk
        # Iterate over each monster in the team
        # and draw its attack value
        @monsters.each {|m| m.draw_atk}
    end

    # Decrease the number of times each monster in the team can use its skill
    #
    # @return [void]
    def charge
        @monsters.each {|m| m.dec_num}
    end

    # Check if the monster at the given index can use its active skill
    #
    # @param i [Integer] The index of the monster
    # @return [Boolean] true if the monster can use its active skill
    def can_active?(i)
        # Check if the index is within the bounds of the array
        # and if the monster at the index is not nil
        # Then check if the monster can use its active skill
        @monsters[i].can_active? if @monsters.at(i) != nil
    end

    # Use the active skill of the monster at the given index
    #
    # @param i [Integer] The index of the monster
    # @return [void]
    def active(i)
        # Check if the index is within the bounds of the array
        # and if the monster at the index is not nil
        # Then use the active skill of the monster
        @monsters[i].active if @monsters.at(i) != nil
    end

    # Reset the team by calling the reset method of each monster
    #
    # @return [void]
    def reset
        # Iterate over each monster in the team and call its reset method
        @monsters.each(&:reset)
    end

    # Increase the team's current life by the total recovery of all monsters
    #
    # @return [void]
    def recovery
        # Increase the current life by the total recovery
        @currLife += total_re
        # Make sure the current life does not exceed the maximum life
        @currLife = @maxLife if @currLife > @maxLife
    end

    # Calculate the total recovery of all monsters
    #
    # @return [Integer] The total recovery of all monsters
    def total_re
        # Initialize the result to 0
        result = 0
        # Iterate over each monster in the team and add its current recovery
        # to the result
        @monsters.each {|m| result += m.currRe}
        # Return the total recovery
        return result
    end

    # Calculate the total attack of all monsters
    #
    # @return [Array<Integer>] An array of the total attack of all monsters
    def damage
        # Initialize the result array
        result = []
        # Iterate over each monster in the team and add its current attack
        # to the result array
        @monsters.each {|m| result << m.currAtk}
        # Return the result array
        return result
    end


    # Take damage from the enemies
    #
    # @param damages [Array<Integer>] The damages taken by the team
    def take_damage(damages)
        # Subtract the damage from the current life
        damages.each {|damage| @currLife -= damage}
    end

    # Check if the team is dead
    #
    # @return [Boolean] Whether the team is dead
    def die?
        # If the current life is less than or equal to 0, the team is dead
        @currLife <= 0
    end

    def currLife; @currLife; end
    def maxLife; @maxLife; end

    private
    # Initialize the team with a list of monster IDs
    #
    # @param [Array<Integer>] ids A list of monster IDs
    def init(ids)
        # Create a Monster object for each ID in the list
        ids.each_index {|i| @monsters << Monster.new(ids[i],i)}
    end

    # Initialize the team's life and maximum life
    #
    # @return [void]
    def init_life
        # Initialize the maximum life to the sum of all monster's HP
        @monsters.each {|m| @maxLife += m.hp}
        # Initialize the current life to the maximum life
        @currLife = @maxLife
    end
end