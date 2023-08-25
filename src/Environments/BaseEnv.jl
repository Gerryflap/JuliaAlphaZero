abstract type State end;

abstract type Action end;

struct NotImplementedException <: Exception end

struct InvalidActionException <: Exception end

# Any environment should implement the following methods for their respective state and action:

"""
    initial_state(::Type{S}) where {S<:State} :: S

Generates an initial state of the given type S
"""
function initial_state(::Type{S}) :: S where {S<:State}
    throw(NotImplementedException())
end

"""
    make_step(s::State, a::Action) :: State

Performs one step, returning a NEW state. 
*NOTE: State should not be mutated!*
"""
function make_step(s::State, a::Action) :: State
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
function get_final_state_rewards(s::State) :: Array{Float64}
    throw(NotImplementedException())
end

"""
    get_current_player(s::State) :: Int

Returns the index of the player whose turn it currently is
"""
function get_current_player(s::State) :: Int
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

"""
    max_reward(s::State) :: Float64

Returns the maximum reward for this environment (or from this state if applicable)
"""
function max_reward(s::State) :: Float64
    throw(NotImplementedException())
end

"""
    state_hash(s::State)::Array{Int64}
Hashes the state.
Should be unique for every distinct state. Should be the same for the same states. 
Used for putting states into sets and dicts.
"""
function state_hash(s::State)::Array{Int64} end