class Timebar
    # Constructor of Timebar
    #
    # @param [Integer] maxLife the maximum health of the player
    # @param [Float] t the time in seconds
    def initialize(maxLife, t=5000.0)
        @ybias = 320
        @inonscale = 0.6
        @font = Gosu::Font.new(25)
        @clock = Image.new("image/Timebar/clock.png",0,0,1)
        @heart = Image.new("image/Timebar/heart.png",0,0,1)
        @timeclip = Image.new("image/Timebar/timeclip.png",0,0,1)
        @lifeclip = Image.new("image/Timebar/lifeclip.png",0,0,1)

        @basedtime = t
        @extratime = 0
        @temptime = 0.0
        @clipsale = 0.8

        @currLife,@maxLife = maxLife,maxLife

        init
    end

    # Update the current life of the player
    #
    # @param [Integer] currLife the current life of the player
    def update_life(currLife)
        @currLife = currLife
    end

    # Draw the life bar of the player
    #
    # @return [nil] Returns nothing
    def draw_lifebar
        # Calculate the width of the life bar
        diff = (@maxLife-@currLife)/@maxLife.to_f
        # Set the position of the life bar
        @lifeclip.set(@heart.w*@inonscale/2-diff*@lifeclip.w,@ybias-@lifeclip.h)

        # Draw the life bar
        @lifeclip.draw(1,@clipsale)
        @heart.draw(@inonscale,@inonscale)
        # Draw the current life and maximum life of the player
        @font.draw_text("#{@currLife}/#{@maxLife}",320,290,2,1.0,1.0,Gosu::Color::YELLOW)
    end

    # Draw the time bar of the player
    #
    # @return [nil] Returns nothing
    def draw_timebar
        # Draw the time bar
        @timeclip.draw(1,@clipsale)
        # Draw the clock
        @clock.draw(@inonscale,@inonscale)
    end
    def draw_re(totalRe)
        if totalRe != 0
            @font.draw_text("+#{totalRe}",200,285,2,1.0,1.0,Gosu::Color.argb(0xff_1AFD9C))
        end
    end

    # Decrease the time bar
    #
    # @param [Float] currtime the current time
    # @return [Boolean] true if the countdown is finished
    def countdown(currtime)
        # The time bar is not moving
        @temptime < currtime and @temptime = currtime+@basedtime+@extratime
        # Calculate the difference between the current time and the time when the time bar should be finished
        difftime = 1.0-(@temptime-currtime)/(@basedtime+@extratime)
        # Set the position of the time bar
        @timeclip.set(@clock.w*@inonscale/2-difftime*@timeclip.w,@ybias-@timeclip.h)
        # Return true if the countdown is finished
        return true if difftime > 0.98
    end

    # Reset the time bar
    #
    # @return [nil] Returns nothing
    def reset_timebar
        # Reset the time bar
        @temptime = 0.0
    end

    # Add extra time to the time bar
    #
    # @param time [Float] The extra time to add
    # @return [nil] Returns nothing
    def add_time(time)
        # Add extra time to the time bar
        @extratime += time
    end

    private

    # Initialize the time bar
    #
    # @return [nil] Returns nothing
    def init
        # Set the position of the clock
        @clock.set(0,@ybias-@clock.h*@inonscale)
        # Set the position of the heart
        @heart.set(0,@ybias-@heart.h*@inonscale)
        # Set the position of the time bar
        @timeclip.set(@clock.w*@inonscale/2,@ybias-@timeclip.h)
        # Set the position of the life bar
        @lifeclip.set(@heart.w*@inonscale/2,@ybias-@lifeclip.h)
    end
end