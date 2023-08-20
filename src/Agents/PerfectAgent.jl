"""
    Models a perfect player. 
    This implementation basically searches the entire tree of possible states, making it very slow in games with many states.
    The implementation assumes a deterministic game (state & action always lead to same next state)
    Any number of players >=1 can be supported, and the games do not have to be zero-sum.
"""

module PerfectAgent
export choose_action
using ...Environments

struct CannotFindActionException <: Exception 
    text :: String
end

function choose_action(s::State) :: Action
    s_final, a = get_optimal_final_state(s)
    return a
end

"""
    get_optimal_final_state(s::State, player_index::Int, prev_action::Int) :: State

Returns the final state you'll end up in from this state if all players pick the action that is most afvantageous for them
"""
function get_optimal_final_state(s::State) :: Tuple{State, Union{Action, Nothing}}
    if is_final_state(s)
        # We can't return the chosen action, since we chose none
        return s, nothing
    end

    # Ghetto Maybe type
    a_optimal :: Union{Action, Nothing} = nothing
    s_optimal :: Union{State, Nothing} = nothing
    r_optimal :: Union{Float64, Nothing} = nothing

    current_player = get_current_player(s)

    for action in action_space(s)
        s_prime = make_step(s, action)
        s_final, _ = get_optimal_final_state(s_prime)
        r_final = get_final_state_rewards(s_final)[current_player]

        if r_optimal === nothing || r_final > r_optimal
            a_optimal = action
            r_optimal = r_final
            s_optimal = s_final
        end
    end

    if s_optimal === nothing
        throw(CannotFindActionException("Optimal state returned nothing! This usually indicates a 0-length action space"))
    end

    return s_optimal, a_optimal
end

end