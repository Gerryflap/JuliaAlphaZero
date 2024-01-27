module SimpleMctsAgent

export MctsAgentState

using Random
import ..Agents
using ...Environments

struct MctsAgentState <: Agents.AgentState
    simulations_per_turn::Int64
end

mutable struct MctsValues
    # Visits
    n::Dict{Array{Int64}, Float64}
    # Wins/Losses
    w::Dict{Array{Int64}, Float64}
end

function Agents.choose_action(agentState::MctsAgentState, s::State) :: Action
    values = MctsValues(Dict(), Dict())
    player = get_current_player(s)
    for i in 1:agentState.simulations_per_turn
        simulate(s, values, player)
    end

    # Pick the best action
    act_space = action_space(s)
    uct_values = [uct(s, make_step(s, action), values, false; c=0.0) for action in act_space]
    println(uct_values)
    index = argmax(uct_values)
    return act_space[index]
end

"""
    simulate(state::State, values::MctsValues, player::Int64) :: Float64

Simulates a possible game from the given state, which populates the MctsValues object given to the method.
Returns the final result, as seen from the perspective of the given player
"""
function simulate(state::State, values::MctsValues, player::Int64) :: Float64
    if is_final_state(state)
        result = get_final_state_rewards(state)[player]
    else
        # Not a final state, continue search
        act_space = action_space(state)
        # We have to choose from the opponent's perspective if we're playing as them, and thus invert w (assuming a 2-player zero-sum game)
        invert_w = get_current_player(state) != player

        # Compute uct scores and pick an action based on them (picking a random action when multiple have the same value)
        uct_values_for_action = [uct(state, make_step(state, action), values, invert_w) for action in act_space]
        max_val = maximum(uct_values_for_action)
        options = act_space[max_val .== uct_values_for_action]
        act::Action = rand(options)

        # # Compute probabilities and pick an action based on them
        # uct_values = [uct(state, make_step(state, action), values, invert_w) for action in act_space]
        # probabilities = softmax(uct_values)
        # act::Action = choose_random(act_space, probabilities)

        new_state = make_step(state, act)
        result = simulate(new_state, values, player)
    end

    # Add one visit and the game result
    sh = state_hash(state)
    n::Float64 = get(values.n, sh, 0)
    values.n[sh] = n + 1

    w::Float64 = get(values.w, sh, 0)
    values.w[sh] = w + result
    return result
end

function uct(parent::State, state::State, values::MctsValues, invert_w::Bool; c::Float64=sqrt(2.0)) :: Float64
    N::Float64 = get(values.n, state_hash(parent), 0)
    n::Float64 = get(values.n, state_hash(state), 0)
    w::Float64 = get(values.w, state_hash(state), 0)
    if invert_w
        w *= -1
    end
    return uct(w, n, N; c=c)
end

"""
    uct(w::Float64, n::Float64, N::Float64; c::Float64=sqrt(2.0)) :: Float64

UCT formula often used in MCTS.
Used to determine the next move to take
...
# Arguments
- `w::Float64`: Number of wins found from the current node so far.
- `n::Float64`: Number of visits to the current node so far.
- `N::Float64`: Number of visits to the parent node so far.
- `c::Float64=sqrt(2.0)`: Scaling factor for exploration. Pick 0 for pure exploitation
...

Note: Will return Inf when n=0 to avoid overflow
"""
function uct(w::Float64, n::Float64, N::Float64; c::Float64=sqrt(2.0)) :: Float64
    if n == 0.0 
        return Inf
    end

    return w/n + c*(log(N)/n)
end

end