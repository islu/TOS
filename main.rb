#coding: utf-8
require 'gosu'
require 'aasm'
require_relative 'lib/DATA'
require_relative 'lib/stone'
require_relative 'lib/board'
require_relative 'lib/timebar'
require_relative 'lib/team'
require_relative 'lib/floor'

class BATTLE_STATE
    include AASM
    aasm do
        state :normal, initial: true
        state :moveing,:deleting,:dropping,:checking,:attacking,:first_checking
        state :first_deleting, :first_dropping
        state :enemy_attacking
        state :finishing

        event :first_delete do
            transitions from: :moveing, to: :first_deleting
        end

        event :first_drop do
            transitions from: :first_deleting, to: :first_dropping
        end

        event :enemy_attack do
            transitions from: :attacking, to: :enemy_attacking
        end

        event :finish do
            transitions from: :normal, to: :finishing
        end

        event :idling do
            transitions from: :deleting, to: :enemy_attacking
        end

        event :move do
            transitions from: :normal, to: :moveing
        end
        event :active do
            transitions from: :normal, to: :first_checking
        end

        event :delete do
            transitions from: :moveing, to: :deleting
        end

        event :drop do
            transitions from: [:deleting,:checking], to: :dropping
        end

        event :again do
            transitions from: :dropping, to: :deleting
        end

        event :check do
            transitions  from: :dropping, to: :checking
        end
        event :attack do
            transitions from: :checking, to: :attacking
        end

        # test
        event :back do
            transitions from: [:enemy_attacking,:first_checking,:moveing,:deleting,:dropping,:attacking], to: :normal
        end
    end
end

class Game < Gosu::Window

    # Create a new window with the given width and height.
    # Also create other components.
    def initialize
        super 480,720
        self.caption = "TOS"
        @board = Board.new
        @team = Team.new([1239, 1239, 1239, 1239, 1239, 1239])
        @timebar = Timebar.new(@team.maxLife)
        @state = BATTLE_STATE.new
        @floor = Floor.new("遠洋的王者")
        # For debugging
        @debug = Gosu::Font.new(25)
        # Set random positions for each stone
        @board.x_possess_y("_f", "_h")

    end

    # Do we need to show the mouse cursor?
    #
    # @return [Boolean] Whether we need to show the mouse cursor.
    def needs_cursor?
        true
    end

    # Called once per frame, updates the state of the game.
    #
    # @return [void]
    def update
        mx,my = mouse_x,mouse_y
        sx,sy = width,height
        currtime = Gosu.milliseconds

        button_down?(Gosu::KB_ESCAPE) and exit

        if button_down?(Gosu::MS_LEFT) and @state.may_move?
            if @board.stone?(mx,my)
                @board.reset_combo_counter
                @team.reset
                @board.drag(mx,my)
                @board.swap(mx,my) and @state.move
            end
            if @team.monster?(mx,my)
                i = @team.index(mx,my)
                @team.can_active?(i) and active_monster_skill(i) & @team.active(i)
            end
        end

        if button_down?(Gosu::MS_LEFT) and @state.moveing?
            @timebar.countdown(currtime) and @state.delete and @board.check_combos and @board.all_delete? and @state.idling
        end
        if button_down?(Gosu::MS_LEFT) and @state.moveing? and @board.stone?(mx,my)
            @board.drag(mx,my)
            @board.swap(mx,my)
        elsif !button_down?(Gosu::MS_LEFT) and @state.moveing?
            @timebar.reset_timebar
            @board.check_combos
            @state.delete and @board.all_delete? and @state.idling
        end

        if @state.deleting?
            @board.all_delete? and @state.drop and @board.search_dropping
            @board.delete_combos(currtime)
        end

        if @state.dropping?
            if @board.dropping
                @board.check_combos

                if @board.all_delete?
                    @state.check
                else
                    @state.again
                end
            end
        end

        if @state.checking?
            if @board.explode_h
                @state.drop and @board.search_dropping
            else
                @state.attack
            end
        end

        if @state.first_checking?
            @state.back
        end

        if @state.attacking?
            @team.charge
            @team.recovery
            map_enemys_skill(@floor.enemys)
            @floor.take_damage(@team.damage)
            @state.enemy_attack
        end

        if @state.enemy_attacking?
            @floor.update
            @team.take_damage(@floor.damage)
            map_enemys_skill(@floor.enemys)

            @state.back
        end

        @floor.all_clear? and @state.may_finish? and @state.finish

        !button_down?(Gosu::MS_LEFT) || @state.deleting? and @board.reset

        !@state.moveing? and !@state.normal? and !@state.dropping? and calculate_atk & calculate_re
        @timebar.update_life(@team.currLife)
        # test
        button_down?(Gosu::KB_Q) and @board.new
        button_down?(Gosu::KB_W) and @board.x_transform_y("_w", "_f")
    end

    # Main drawing method.
    #
    # @return [void]
    def draw
        mx,my = mouse_x,mouse_y
        sx,sy = width,height

        # Draw the game board.
        @board.draw

        # Draw the wave and enemies.
        @floor.draw_enemys
        @floor.draw_wave

        # If the game is in the normal state, draw the skills of the monsters.
        if @state.normal?
            @floor.draw_skills(mx,my)
        end

        # Draw the icons of the monsters.
        @team.draw_icon

        # If the mouse is over a monster, draw its skill.
        if @state.normal? and @team.monster?(mx,my)
            @team.draw_skill(@team.index(mx,my))
        end

        # If the game is not in the normal state, draw the monster's attack.
        if !@state.normal? and !@state.moveing?
            @team.draw_atk
        end

        # If the game is not in the normal state, draw the total recovery.
        if !@state.normal? and !@state.moveing?
            @timebar.draw_re(@team.total_re)
        end

        # If the game is not in the normal state, draw the combo counter.
        if !@state.normal? and !@state.moveing?
            @board.draw_combo
        end

        # If the game is not in the moving state, draw the lifebar.
        if !@state.moveing?
            @timebar.draw_lifebar
        end

        # If the game is in the moving state, draw the timebar.
        if @state.moveing?
            @timebar.draw_timebar
        end

        # If the game is in the finishing state, draw "VICTORY !!!".
        if @state.finishing?
            @debug.draw_text("VICTORY !!!", 185, 100, 2, 1.0, 1.0, Gosu::Color::YELLOW)
        end

        # For debugging.
        #@debug.draw_text("#{mx} , #{my}", 0, 0, 2, 1.0, 1.0, Gosu::Color::WHITE)
        #@debug.draw_text("center", 200, 100, 2, 1.0, 1.0, Gosu::Color::WHITE)

    end

    private

    # Activate the active skill of the monster at the given index.
    #
    # @param monsterOrder [Integer] The index of the monster
    # @return [void]
    def active_monster_skill(monsterOrder)
        monsterId = @team.id(monsterOrder)
        case monsterId
            # 1224: No implementation yet.
            when 1239
                # All transform and enchant fire.
                @board.all_transform
                @board.enchante("_f")
        end
        @state.active
    end

    # Map the skill of the leader to the target.
    #
    # @param leader [Monster] The leader
    # @param target [Monster] The target
    # @return [Float] The magnification of the attack
    def map_leader_skill(leader, target)
        # The magnification of the attack
        magn = 1.0

        # Handle the skill of the leader
        case leader.id
        when 1239
            # If the target is a fire type, magnify the attack
            if target.attr == "_f"
                magn = 3.2

                # If there are 4 or more types of dissolving, magnify the attack
                if @board.dissolving_types >= 4
                    magn *= 1.8
                # If there are 3 types of dissolving, magnify the attack
                elsif @board.dissolving_3_types?
                    magn *= 1.5
                end
            end
        end

        # Return the magnification
        return magn
    end

    # Map the skills of the enemies to the team.
    #
    # @param enemys [Array<Enemy>] The enemies
    def map_enemys_skill(enemys)
        # Iterate over each enemy
        enemys.each do |e|
            # Handle the skill of the enemy
            case e.characteristic
            when 75
                # If there are no water, fire, and earth dissolving, set the attack of each monster to 1
                if !@board.dissolving_wfe?
                    @team.monsters.each {|m| m.update_atk(1)}
                end
            when 100
                # If the enemy is attacking, transform water to the enemy's element
                @state.enemy_attacking? and @board.x_transform_y("_w", e.attr)
            end
        end
    end

    # Calculate the attack of each monster
    #
    # @return [void]
    def calculate_atk
        # Get the leaders of the team
        leader1 = @team.first_leader
        leader2 = @team.second_leader

        # Iterate over each monster in the team
        @team.monsters.each do |m|
            # Calculate the attack of the monster
            atk = m.atk
            atk *= map_leader_skill(leader1, m)
            atk *= map_leader_skill(leader2, m)
            atk *= @board.calculate_atk(m.attr)

            # Update the attack of the monster
            m.update_atk(atk.floor)
        end
    end

    # Calculate the recovery of each monster.
    #
    # @return [void]
    def calculate_re
        # Get the leaders of the team
        leader1 = @team.first_leader
        leader2 = @team.second_leader

        # Iterate over each monster in the team
        @team.monsters.each do |m|
            # Calculate the recovery of the monster
            re = m.re
            re *= @board.calculate_re
            re *= map_leader_skill(leader1, m)
            re *= map_leader_skill(leader2, m)

            # Update the recovery of the monster
            m.update_re(re.floor)
        end
    end
end

# Run the game
Game.new.show
