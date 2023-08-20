"""
    Models a perfect player. 
    This implementation basically searches the entire tree of possible states, apart from states that logically speaking will never be chosen.
    The implementation assumes a deterministic game (state & action always lead to same next state)
    This agent contains optimizations that assume a 2-player zero-sum game, where players take turns.
    Any game that does not match these assumptions might lead to incorrect results
"""

module AlphaBetaPerfectAgent
export choose_action
using ...Environments

struct CannotFindActionException <: Exception 
    text :: String
end

function choose_action(s::State) :: Action
    s_final, a = get_optimal_final_state(s, -Inf)
    return a
end

"""
    get_optimal_final_state(s::State, current_max::Float64) :: Tuple{Union{State, Nothing}, Union{Action, Nothing}}

Returns the final state you'll end up in from this state if both players pick the action that is most advantageous for them.
Used the current_max to determine whether to keep on searching, because there's no use to continue searching if this tree would lead to a lower score for the other player
"""
function get_optimal_final_state(s::State, current_max::Float64) :: Tuple{Union{State, Nothing}, Union{Action, Nothing}}
    if is_final_state(s)
        # We can't return the chosen action, since we chose none
        return s, nothing
    end

    # Ghetto Maybe type
    a_optimal :: Union{Action, Nothing} = nothing
    s_optimal :: Union{State, Nothing} = nothing
    r_optimal :: Float64 = -Inf

    current_player = get_current_player(s)

    for action in action_space(s)
        s_prime = make_step(s, action)
        s_final, _ = get_optimal_final_state(s_prime, r_optimal)

        if s_final === nothing
            continue
        end

        r_final = get_final_state_rewards(s_final)[current_player]

        if r_final > r_optimal
            a_optimal = action
            r_optimal = r_final
            s_optimal = s_final
        end

        if r_optimal >= max_reward(s)
            break
        end

        if r_optimal > -current_max
            return nothing, nothing
        end
    end

    if s_optimal === nothing
        throw(CannotFindActionException("Optimal state returned nothing! This usually indicates a 0-length action space"))
    end

    return s_optimal, a_optimal
end

end