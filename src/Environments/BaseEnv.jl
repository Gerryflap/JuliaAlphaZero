module BaseEnv
export State, Action, step, is_final_state, get_final_state_rewards, action_space, is_valid_action, NotImplementedException, InvalidActionException, render

abstract type State end;

abstract type Action end;

struct NotImplementedException <: Exception end

struct InvalidActionException <: Exception end

module DefaultDefinitions
    using ..BaseEnv
    """
        initial_state() :: State

    Generates an initial state for the game
    """
    function initial_state() :: State
        throw(NotImplementedException())
    end

    """
        step(s::State, a::Action) :: State

    Performs one step, returning a NEW state. 
    *NOTE: State should not be mutated!*
    """
    function step(s::State, a::Action) :: State
        throw(NotImplementedException())
    end

    """
        is_final_state(s::State) :: Bool

    Returns whether this is a final state. (i.e. the game is over)
    """
    function is_final_state(s::State) :: Bool
        throw(NotImplementedException())
    end

    """
        get_final_state_rewards(s::State) :: Array{Int}

    Returns an array with rewards for each player at the end of the game. Usually -1 for losers, 0 for draw, 1 for winners
    """
    function get_final_state_rewards(s::State) :: Array{Int}
        throw(NotImplementedException())
    end

    """
        action_space(s::State) :: Array{Action}

    Gives an Array of all possible actions
    """
    function action_space(s::State) :: Array{Action}
        throw(NotImplementedException())
    end

    """
        is_valid_action(s::State, a::Action) :: Bool

    Returns whether the action can be taken in the current state
    """
    function is_valid_action(s::State, a::Action) :: Bool
        throw(NotImplementedException())
    end

    """
    render(s::State)

    Renders the state in some way
    """
    function render(s::State)
        println(s)
    end
end

end