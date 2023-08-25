module TicTacToe
export TttState, TttAction, initial_state, make_step, is_final_state, get_final_state_rewards, action_space, is_valid_action, render, get_current_player

using Match
import ..Environments

struct TttState <: Environments.State
    board :: Array{Int}
    player :: Int
end

struct TttAction <: Environments.Action
    x :: Int
    y :: Int
    player :: Int
end

function Environments.initial_state(::Type{TttState}) :: TttState
    return TttState(zeros(3,3), 1)
end

function Environments.make_step(s::TttState, a::TttAction) :: TttState
    if (!Environments.is_valid_action(s, a))
        throw(Environments.InvalidActionException())
    end
    board = copy(s.board)
    player = s.player
    board[a.x, a.y] = a.player
    player = (a.player) % 2 + 1
    return TttState(board, player)
end

function all_equal_and_not_0(arr::Array{Int})
    return all((arr[1] .== arr) .&& (0 .!= arr))
end

function get_winner_and_final_state(s::TttState) :: Tuple{Bool, Int}
    for x in 1:3
        if all_equal_and_not_0(s.board[x, 1:end])
            return true, s.board[x, 1]
        end
    end

    for y in 1:3
        if all_equal_and_not_0(s.board[1:end, y])
            return true, s.board[1, y]
        end
    end

    if all(0 .!= s.board)
        return true, 0
    end

    if (all_equal_and_not_0(s.board[CartesianIndex.([(1,1), (2,2), (3,3)])]))
        return true, s.board[1,1]
    end

    if (all_equal_and_not_0(s.board[CartesianIndex.([(1,3), (2,2), (3,1)])]))
        return true, s.board[1,3]
    end

    return false, 0
end

function Environments.is_final_state(s::TttState) :: Bool
    result, _ = get_winner_and_final_state(s)
    return result
end

function Environments.get_final_state_rewards(s::TttState) :: Array{Float64}
    _, winner = get_winner_and_final_state(s)
    return @match winner begin
        0 => [ 0.0  0.0]     # Draw
        1 => [ 1.0 -1.0]    # P1 win
        2 => [-1.0  1.0]
    end
end

function Environments.get_current_player(s::TttState) :: Int
    return s.player
end


function Environments.action_space(s::TttState) :: Array{TttAction}
    actions = []
    for x in 1:3
        for y in 1:3
            if s.board[x,y] == 0
                push!(actions, TttAction(x, y, s.player))
            end
        end
    end
    return actions
end

function Environments.is_valid_action(s::TttState, a::TttAction) :: Bool
    return a.x in 1:3 && a.y in 1:3 && s.board[a.x, a.y] == 0 && a.player == s.player
end

function Environments.render(s::TttState)
    str = ""
    for y in 1:3
        for x in 1:3
            str *= @match s.board[x, y] begin
                0 => "_"
                1 => "X"
                2 => "O"
            end
        end
        str *= "\n"
    end
    println(str)
end

function Environments.max_reward(s::TttState) :: Float64
    return 1.0
end

function Environments.state_hash(s::TttState)::Array{Int64}
    result = zeros(Int64, (10,))
    result[1:9] = reshape(s.board, (9,))
    result[10] = s.player
    return result
end

end