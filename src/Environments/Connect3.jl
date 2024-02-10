module Connect3
export C3State, C3Action, initial_state, make_step, is_final_state, get_final_state_rewards, action_space, is_valid_action, render, get_current_player

using Match
import ..Environments

struct C3Action <: Environments.Action
    x :: Int
    player :: Int
end

struct C3State <: Environments.State
    board :: Array{Int}
    player :: Int
    # Used for more efficient win condition checking
    last_action :: Union{C3Action,Nothing}
end

function Environments.initial_state(::Type{C3State}) :: C3State
    return C3State(zeros(5, 4), 1, nothing)
end

function drop_stone(x :: Int, board::Array{Int}, player :: Int)
    # From bottom up, find the first empty slot and put the player token there
    for y in 1:6 
        if board[x, y] == 0
            board[x, y] = player
            break
        end
    end
end

function Environments.make_step(s::C3State, a::C3Action) :: C3State
    if (!Environments.is_valid_action(s, a))
        throw(Environments.InvalidActionException())
    end
    board = copy(s.board)
    player = s.player

    drop_stone(a.x, board, player)
    player = (a.player) % 2 + 1
    return Environments.C3State(board, player, a)
end

function all_equal_and_not_0(arr::Array{Int})
    return all((arr[1] .== arr) .&& (0 .!= arr))
end

function get_winner_and_final_state(s::C3State) :: Tuple{Bool, Int}
    if s.last_action === nothing
        return false, 0
    end

    for x in 1:3
        for y in 1:4
            if all_equal_and_not_0(s.board[x:x+2, y])
                return true, s.board[x, y]
            end
        end
    end


    for y in 1:2
        if all_equal_and_not_0(s.board[s.last_action.x, y:y+2])
            return true, s.board[s.last_action.x, y]
        end
    end


    for x in 1:3
        for y in 1:2
            if all_equal_and_not_0([s.board[x+d, y+d] for d in 0:2])
                return true, s.board[x, y]
            end

            if all_equal_and_not_0([s.board[6 - x - d, y+d] for d in 0:2])
                return true, s.board[x, y]
            end
        end
    end

    if all(0 .!= s.board[1:end, 4])
        return true, 0
    end

    return false, 0
end

function Environments.is_final_state(s::C3State) :: Bool
    result, _ = get_winner_and_final_state(s)
    return result
end

function Environments.get_final_state_rewards(s::C3State) :: Array{Float64}
    _, winner = get_winner_and_final_state(s)
    return @match winner begin
        0 => [ 0.0  0.0]     # Draw
        1 => [ 1.0 -1.0]    # P1 win
        2 => [-1.0  1.0]
    end
end

function Environments.get_current_player(s::C3State) :: Int
    return s.player
end


function Environments.action_space(s::C3State) :: Array{C3Action}
    actions = []
    for x in 1:5
        if s.board[x,4] == 0
            push!(actions, C3Action(x, s.player))
        end
    end
    return actions
end

function Environments.is_valid_action(s::C3State, a::C3Action) :: Bool
    return s.board[a.x, 4] == 0 && a.player == s.player
end

function Environments.render(s::C3State)
    str = ""
    for y in 4:-1:1
        for x in 1:5
            str *= "|"
            str *= @match s.board[x, y] begin
                0 => "_"
                1 => "X"
                2 => "O"
            end
        end
        str *= "|\n"
    end
    println(str)
end

function Environments.max_reward(s::C3State) :: Float64
    return 1.0
end

function Environments.state_hash(s::C3State)::Array{Int64}
    result = zeros(Int64, (21,))
    result[1:20] = reshape(s.board, (20,))
    result[20] = s.player
    return result
end

end