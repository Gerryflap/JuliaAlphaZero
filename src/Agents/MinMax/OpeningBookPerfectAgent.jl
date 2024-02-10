"""
    Models a perfect player, which can be supported by an "opening book" to speed up inference times.
    This implementation basically searches the entire tree of possible states, which is why an opening book is required for speed.
    Computing the opening book has to be done once, and will take a long time.
    The implementation assumes a deterministic game (state & action always lead to same next state)
    Any number of players >=1 can be supported, and the games do not have to be zero-sum.
"""

module OpeningBookPerfectAgent
export choose_action, ObPerfectAgentState, compute_opening_book, load_opening_book, save_opening_book
import ..Agents
using ...Environments
using Serialization

struct OpeningBook
    book :: Dict{State, State}
    max_depth :: Int
end

struct ObPerfectAgentState <: Agents.AgentState 
    book :: OpeningBook
end

struct CannotFindActionException <: Exception 
    text :: String
end

function Agents.choose_action(agentState::ObPerfectAgentState, s::State) :: Action
    s_final, a = get_optimal_final_state(agentState, s)
    return a
end

"""
    get_optimal_final_state(s::State, player_index::Int, prev_action::Int) :: State

Returns the final state you'll end up in from this state if all players pick the action that is most afvantageous for them.
Uses the opening book for a speed advantage.
"""
function get_optimal_final_state(agentState::ObPerfectAgentState, s::State) :: Tuple{State, Union{Action, Nothing}}
    if is_final_state(s)
        # We can't return the chosen action, since we chose none
        return s, nothing
    end

    a_optimal :: Union{Action, Nothing} = nothing
    s_optimal :: Union{State, Nothing} = nothing
    r_optimal :: Union{Float64, Nothing} = nothing

    current_player = get_current_player(s)

    for action in action_space(s)
        s_prime = make_step(s, action)

        s_final = get_perfect_result(agentState.book, s_prime)
        if isnothing(s_final)
            s_final, _ = get_optimal_final_state(agentState, s_prime)
        end

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

"""
    Computes the complete opening book for all players, given an initial state and the max_depth. 
        The max_depth determines the size of the opening book. It will only contain states up to that depth in order to constrain the memory size.
"""
function compute_opening_book(initial_state::State, max_depth::Int) :: OpeningBook
    book = OpeningBook(Dict(), max_depth)
    create_opening_book(initial_state, 1, book)
    return book
end

"""
Returns the final state you'll end up in from this state if all players pick the action that is most afvantageous for them.
On the way, it logs the final states for any state lower or equal to the max_depth of the opening book.
"""
function create_opening_book(s::State, current_depth::Int, book::OpeningBook) :: State
    if is_final_state(s)
        # We can't return the chosen action, since we chose none
        return s
    end

    if s ∈ keys(book.book)
        return book.book[s]
    end    

    a_optimal :: Union{Action, Nothing} = nothing
    s_optimal :: Union{State, Nothing} = nothing
    r_optimal :: Union{Float64, Nothing} = nothing

    current_player = get_current_player(s)

    for action in action_space(s)
        s_prime = make_step(s, action)
        s_final = create_opening_book(s_prime, current_depth + 1, book)
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

    if current_depth <= book.max_depth
        update_opening_book(book, s, s_optimal)
    end

    return s_optimal
end

function update_opening_book(book::OpeningBook, s_current::State, s_final::State)
    book.book[s_current] = s_final
end

function get_perfect_result(book::OpeningBook, s_current::State) :: Union{State, Nothing}
    return get(book.book, s_current, nothing)
end

function save_opening_book(book::OpeningBook, file_path::String)
    serialize(file_path, book)
end

function load_opening_book(file_path::String)::Union{OpeningBook, Nothing}
    if isfile(file_path)
        return deserialize(file_path)
    else
        return nothing
    end
end

end