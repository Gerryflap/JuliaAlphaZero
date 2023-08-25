module Connect4
export C4State, C4Action, initial_state, make_step, is_final_state, get_final_state_rewards, action_space, is_valid_action, render, get_current_player

using Match
import ..Environments

struct C4Action <: Environments.Action
    x :: Int
    player :: Int
end

struct C4State <: Environments.State
    board :: Array{Int}
    player :: Int
    # Might be used for more efficient win condition checking later
    last_action :: Union{C4Action,Nothing}
end

function Environments.initial_state(::Type{C4State}) :: C4State
    return C4State(zeros(7, 6), 1, nothing)
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

function Environments.make_step(s::C4State, a::C4Action) :: C4State
    if (!Environments.is_valid_action(s, a))
        throw(Environments.InvalidActionException())
    end
    board = copy(s.board)
    player = s.player

    drop_stone(a.x, board, player)
    player = (a.player) % 2 + 1
    return Environments.C4State(board, player, a)
end

function all_equal_and_not_0(arr::Array{Int})
    return all((arr[1] .== arr) .&& (0 .!= arr))
end

function get_winner_and_final_state(s::C4State) :: Tuple{Bool, Int}
    if s.last_action === nothing
        return false, 0
    end

    for x in 1:4
        for y in 1:6
            if all_equal_and_not_0(s.board[x:x+3, y])
                return true, s.board[x, y]
            end
        end
    end


    for y in 1:3
        if all_equal_and_not_0(s.board[s.last_action.x, y:y+3])
            return true, s.board[s.last_action.x, y]
        end
    end


    for x in 1:4
        for y in 1:3
            if all_equal_and_not_0([s.board[x+d, y+d] for d in 0:3])
                return true, s.board[x, y]
            end

            if all_equal_and_not_0([s.board[8 - x - d, y+d] for d in 0:3])
                return true, s.board[x, y]
            end
        end
    end

    if all(0 .!= s.board[1:end, 6])
        return true, 0
    end

    return false, 0
end

function Environments.is_final_state(s::C4State) :: Bool
    result, _ = get_winner_and_final_state(s)
    return result
end

function Environments.get_final_state_rewards(s::C4State) :: Array{Float64}
    _, winner = get_winner_and_final_state(s)
    return @match winner begin
        0 => [ 0.0  0.0]     # Draw
        1 => [ 1.0 -1.0]    # P1 win
        2 => [-1.0  1.0]
    end
end

function Environments.get_current_player(s::C4State) :: Int
    return s.player
end


function Environments.action_space(s::C4State) :: Array{C4Action}
    actions = []
    for x in 1:7
        if s.board[x,6] == 0
            push!(actions, C4Action(x, s.player))
        end
    end
    return actions
end

function Environments.is_valid_action(s::C4State, a::C4Action) :: Bool
    return s.board[a.x, 6] == 0 && a.player == s.player
end

function Environments.render(s::C4State)
    str = ""
    for y in 6:-1:1
        for x in 1:7
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

function Environments.max_reward(s::C4State) :: Float64
    return 1.0
end

function Environments.state_hash(s::C4State)::Array{Int64}
    result = zeros(Int64, (43,))
    result[1:42] = reshape(s.board, (42,))
    result[43] = s.player
    return result
end

end