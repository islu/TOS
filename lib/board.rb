class Board
    # Create a new board
    #
    # @param comboMagn [Float] The magnification of the combo score
    def initialize(comboMagn=0.25)
        # Initialize the board
        @stones = []
        @boardback = []
        @col,@row = 5,6
        @stonesize = 80
        @ybias = 320
        @currstone = nil

        # Initialize the combo score
        @combostack = []
        @temptime = 0.0
        @deletspeed = 450.0
        @combocounter = 0
        @combosound = ComboSound.new
        @combotext = Gosu::Font.new(50)
        @combotext2 = Gosu::Font.new(30)
        @comboMagn = comboMagn

        # Initialize the drop stack
        @dropstack = []
        @trun = 0

        # Initialize the record hash
        @record = {
            "_w"=>0,"_f"=>0,"_e"=>0,"_l"=>0,"_d"=>0,"_h"=>0,
            "_w_en"=>0,"_f_en"=>0,"_e_en"=>0,"_l_en"=>0,"_d_en"=>0,"_h_en"=>0,
            "_w_set"=>0,"_f_set"=>0,"_e_set"=>0,"_l_set"=>0,"_d_set"=>0,"_h_set"=>0
        }
        # Initialize the previous record hash
        @pre_record = {
            "_w"=>0,"_f"=>0,"_e"=>0,"_l"=>0,"_d"=>0,"_h"=>0,
            "_w_en"=>0,"_f_en"=>0,"_e_en"=>0,"_l_en"=>0,"_d_en"=>0,"_h_en"=>0,
            "_w_set"=>0,"_f_set"=>0,"_e_set"=>0,"_l_set"=>0,"_d_set"=>0,"_h_set"=>0
        }

        # Initialize the possess hash
        @possessHash = {}

        # Initialize the board
        init
    end

    def record; @record; end

    # Replace all the stones that have attribute x with attribute y
    #
    # @param x [String] The attribute to replace
    # @param y [String] The attribute to replace with
    def x_transform_y(x, y)
        # Loop through all the stones
        @stones.each do |s|
            # If the stone has attribute x
            if s.attr?(x)
                # Replace it with attribute y
                s.transform_to_x(y)
                # Update the image
                s.update_img
            end
        end
    end

    # Check if the stone has attribute x
    #
    # @param x [String] The attribute to check
    # @return [Boolean] Whether the stone has attribute x
    def has_attr?(x)
        @stones.each do |s|
            return true if s.attr?(x)
        end
        false
    end

    # Replace all the stones that have attribute x with attribute y
    #
    # @param x [String] The attribute to replace
    # @param y [String] The attribute to replace with
    def x_transform_y(x, y)
        # Loop through all the stones
        @stones.each do |s|
            # If the stone has attribute x
            if s.attr?(x)
                # Replace it with attribute y
                s.transform_to_x(y)
                # Update the image
                s.update_img
            end
        end
    end

    # Set stones with attribute x to also have attribute y
    #
    # @param x [String] The attribute to set
    # @param y [String] The attribute to set to
    # @param prob [Float] The probability of setting the attribute
    def x_possess_y(x, y, prob=1.0)
        if @possessHash.has_key?(y)
            @possessHash[y] = @possessHash[y] << x
        else
            @possessHash[y] = [x]
        end
        #puts "#{x}屬性兼具#{y}屬性#{prob*100}%"
    end

    # Check if the light and dark stones are both dissolving
    #
    # @return [Boolean] Whether both light and dark stones are dissolving
    def dissolving_ld?
        count = 0
        count +=1 if @record["_l"]!=0 || @record["_l_en"]!=0
        count +=1 if @record["_d"]!=0 || @record["_d_en"]!=0
        # Return true if both light and dark stones are dissolving
        return count == 2
    end

    # Check if water, fire and earth stones are all dissolving
    #
    # @return [Boolean] Whether all three types of stones are dissolving
    def dissolving_wfe?
        # Count the number of types of stones that are dissolving
        count = 0
        count +=1 if @record["_w"]!=0 || @record["_w_en"]!=0
        count +=1 if @record["_f"]!=0 || @record["_f_en"]!=0
        count +=1 if @record["_e"]!=0 || @record["_e_en"]!=0
        # Return true if all three types of stones are dissolving
        return count == 3
    end

    # Check if exactly 3 types of stones are dissolving
    #
    # @return [Boolean] Whether exactly 3 types of stones are dissolving
    def dissolving_3_types?
        # Return true if the number of types of stones that are dissolving is 3
        return dissolving_types == 3;
    end

    # Count the number of types of stones that are dissolving
    #
    # @return [Integer] The number of types of stones that are dissolving
    def dissolving_types
        # Count the number of types of stones that are dissolving
        count = 0
        count +=1 if @record["_w"]!=0 || @record["_w_en"]!=0 # Water stones
        count +=1 if @record["_f"]!=0 || @record["_f_en"]!=0 # Fire stones
        count +=1 if @record["_e"]!=0 || @record["_e_en"]!=0 # Earth stones
        count +=1 if @record["_l"]!=0 || @record["_l_en"]!=0 # Light stones
        count +=1 if @record["_d"]!=0 || @record["_d_en"]!=0 # Dark stones
        count +=1 if @record["_h"]!=0 || @record["_h_en"]!=0 # Heart stones
        #puts "消除#{count}種符石"
        return count
    end

    # Calculate the recovery of the team
    #
    # @return [Float] The amount of recovery
    def calculate_re
        # Calculate the recovery of the team
        # The recovery is the same as the attack of heart stones
        calculate_atk("_h")
    end

    # Calculate the attack of the team
    #
    # @param attr [String] The attribute of the stones to calculate the attack of
    # @return [Float] The amount of attack
    def calculate_atk(attr)
        # Calculate the magnification of the combo
        comboMagn = 1 + (@combocounter-1)*@comboMagn

        # Calculate the magnification of the stones
        stoneMagn = @record[attr]*0.25 + @record[attr+"_en"]*0.4 + @record[attr+"_set"]*0.25

        # Add the magnification of the possessed stones
        if @possessHash.has_key?(attr)
            @possessHash[attr].each {|a| stoneMagn += @record[a]*0.25 + @record[a+"_en"]*0.4 + @record[a+"_set"]*0.25}
        end

        # Return the attack of the team
        return comboMagn * stoneMagn
    end

    # Drop dark and enchanted dark stones
    #
    # @return [Integer] The number of dark and enchanted dark stones that are dropped
    def drop_d_en
        # The number of dark and enchanted dark stones to drop
        num = @pre_record["_d"] + @pre_record["_d_en"]

        # Drop two dark stones for every three dark stones
        num = num/3*2

        # Drop the stones
        num.times { @dropstack<<["_d","_en",""] }

        # Return the number of stones that are dropped
        return num
    end

    def explode(attr)
        c = []
        @stones.each_index {|i|
            c<<i if @stones[i].attr == attr
        }
        return false if c.empty?
        c.each {|i|
            @stones[i].nostone
            @stones[i].update_img
        }
        return true
    end

    def explode_h; explode("_h"); end;

    def enchante(attr)
        c = []
        @stones.each_index {|i|
            c<<i if @stones[i].attr == attr
        }
        return false if c.empty?
        c.each {|i|
            @stones[i].enchante
            @stones[i].update_img
        }
        return true
    end
    def all_transform
        prob = ["_w","_f","_e","_f","_h"]
        @stones.each do |s|
            s.transform_to_x(prob.sample)
            s.update_img
        end
        return true
    end

    def dropping
        done = true
        @stones.each_index do |i|
            x,y = coord(i)
            if @stones[i].y != y*@stonesize+@ybias
                @stones[i].drop
                done = false
            end
        end
        return done
    end

    def search_dropping
        len = @stones.length
        temp = []
        (len-1).downto(0) do |i|
            if @stones[i].deleted?
                j = dfs_up(i-6)
                if j.nil?
                    temp<<i
                else
                    @stones[i],@stones[j] = @stones[j],@stones[i]
                end
            end
        end

        temp.shuffle!
        unless @dropstack.empty? || temp.empty?
            attr = @dropstack.pop
            i = temp.pop
            x,y = coord(i)
            @stones[i].new(attr[0],attr[1],attr[2])
            @stones[i].set(x*@stonesize,y*@stonesize+80)
        end

        temp.each do |i|
            x,y = coord(i)
            @stones[i].new
            @stones[i].set(x*@stonesize,y*@stonesize+80)
        end
    end

    def dfs_up(i)
        return nil if i < 0
        if @stones[i].deleted?
            dfs_up(i-6)
        else
            return i
        end
    end

    def delete_combos(currtime)
        if @temptime < currtime
            @temptime = currtime + @deletspeed
            delete
        end
    end

    def reset_combo_counter
        @combocounter = 0
        @record = {
            "_w"=>0,"_f"=>0,"_e"=>0,"_l"=>0,"_d"=>0,"_h"=>0,
            "_w_en"=>0,"_f_en"=>0,"_e_en"=>0,"_l_en"=>0,"_d_en"=>0,"_h_en"=>0,
            "_w_set"=>0,"_f_set"=>0,"_e_set"=>0,"_l_set"=>0,"_d_set"=>0,"_h_set"=>0
        }
    end
    def delete
        c = @combostack.pop
        return nil if c == nil
        #@dropstack<<@stones[c.last].attr if c.length >= 5
        @dropstack<< [@stones[c.last].attr,"_en",""] if c.length >= 5
        @combocounter += 1
        @combosound.play(@combocounter)

        @record["#{@stones[c.last].attr}_set"] += 1

        c.each {|i|
            attr = @stones[i].attr
            en = @stones[i].en
            # 紀錄符石屬性數量及強化數量
            @record["#{attr}#{en}"] += 1
            @stones[i].nostone
            @stones[i].update_img
        }

    end


    def all_delete?
        @combostack.empty?
    end

    def check_combos
        # check row
        @combostack = []
        combo = []
        for i in 0...@col
            for j in 0...@row
                index = i*@row+j
                if combo.empty? or same_stone?(combo.last,index)
                    combo<<index
                else
                    @combostack<<combo if combo.length >= 3
                    combo = []
                    combo<<index
                end
            end
            @combostack<<combo if combo.length >= 3
            combo = []
        end
        # check col
        combo = []
        for i in 0...@row
            for j in 0...@col
                index = i+j*@row
                if combo.empty? or same_stone?(combo.last,index)
                    combo<<index
                else
                    @combostack<<combo if combo.length >= 3
                    combo = []
                    combo<<index
                end
            end
            @combostack<<combo if combo.length >= 3
            combo = []
        end
        # merge combostack
        tempcombostack = []
        tempcombo = []
        visited = []
        len = @combostack.length
        for i in 0...len
            next if visited.include?(i)
            tempcombo = @combostack[i]
            for j in i+1...len
                next if visited.include?(j)
                c1,c2 = @combostack[i],@combostack[j]
                if same_stone?(c1.last,c2.last) and merge?(c1,c2)
                    tempcombo = tempcombo.union(c2)
                    visited<<j
                end
            end
            tempcombostack<<tempcombo
        end

        @combostack = tempcombostack

        return @combostack
    end

    def merge?(combo1, combo2)
        return false if combo1==nil or combo2==nil
        combo1.each {|c| combo2.include?(c) and return true }

        combo1.each do |c|
            neig = neighbor_index(c)
            neig.each {|n| combo2.include?(n) and return true }
        end

        return false
    end

    def neighbor_index(i)
        neighbors = []
        neighbors<<i+1 if i/6 == (i+1)/6
        neighbors<<i-1 if i/6 == (i-1)/6
        neighbors<<i-6 if i-6 >= 0
        neighbors<<i+6 if i+6 < @row*@col
        return neighbors
    end

    def same_stone?(i1,i2)
        @stones[i1].attr == @stones[i2].attr
    end

    def stone?(mx,my)
        !(my<@ybias || my>@ybias+@stonesize*@col || mx<0 || mx>@stonesize*@row)
    end
    # 交換符石
    def swap(mx,my)
        i = index(mx,my)
        if i != @currstone
            @stones[i],@stones[@currstone] = @stones[@currstone],@stones[i]
            # 重新定位符石位置
            x,y = coord(@currstone)
            @stones[@currstone].set(x*@stonesize,y*@stonesize+@ybias)
            @currstone = i
            return true
        else
            return false
        end
    end
    def drag(mx,my)
        i = index(mx,my)
        @currstone = i if @currstone == nil
        @stones[@currstone].drag(mx,my)
    end

    # 重新定位被點擊符石的位置
    def reset
        if @currstone != nil
            x,y = coord(@currstone)
            @stones[@currstone].set(x*@stonesize,y*@stonesize+@ybias)
        @currstone = nil
        end
    end

    def index(mx,my)
        x,y = (mx/@stonesize).floor,((my-@ybias)/@stonesize).floor
        return y*6+x
    end
    def coord(i)
        x,y = i%6,i/6
        return x,y
    end
    # 產生新的盤面
    def new
        @stones.each {|stone|
            stone.transform_to_random
            stone.update_img
        }
    end

    def draw
        @stones.each {|stone| stone.draw}
        @boardback.each {|img| img.draw}
    end
    def draw_combo
        @combotext.draw_text("#{@combocounter} combo!!", 250, 650, 2, 1.0, 1.0, Gosu::Color::YELLOW)
        @combotext2.draw_text("+#{@combocounter*@comboMagn*100.0}%", 330, 625, 2, 1.0, 1.0, Gosu::Color::YELLOW)
    end
    private
    def init
        c = 0
        for i in 0...@col
            for j in 0...@row
                @stones << Stone.new(j*@stonesize,i*@stonesize+@ybias)
                @boardback << Image.new("image/board_back_#{c%2+1}.png",j*@stonesize,i*@stonesize+@ybias,0)
                c += 1
            end
            c += 1
        end
    end
end

class ComboSound
    def initialize
        @sound = []
        init
    end
    def play(i)
        if i >= 9
            @sound[-1].play
        else
            @sound[i-1].play
        end
    end
    private
    def init
        10.times {|i| @sound<<Gosu::Sample.new("sound/combo/combo#{i+1}.wav")}
    end
end
