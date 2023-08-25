module Checkers

import ..Environments

struct Piece
    player::Int64
    king::Bool
end

Position = Tuple{Int64, Int64}
Tile = Union{Nothing, Piece}

# Allow us to use zeros for the piece type
Base.zero(::Type{Tile}) = nothing

struct CheckersState
    board::Array{Tile}
    player::Int64
end

struct CheckersAction
    from::Position
    # Denotes the immediate target location, not the final location after taking pieces
    to::Position
end

function get_pieces_taken(state::CheckersState, from::Position, player::Int64, taken::Set{Position}) :: List{Position}
    for direction in [(-1, -1), (1, -1), (-1, 1), (1, 1)]
        x, y = from .+ direction
        if x in 1:10 && y in 1:10 && player != state.board[x, y].player
            tx, ty = from .+ (2 .* direction)
            if tx in 1:10 && ty in 1:10 && state.board[tx, ty] === nothing
                # We can take the piece, continue
                new_set = copy(taken)
                push!(new_set, (tx, ty))

    end
end

function Environments.initial_state(::Type{CheckersState}) :: CheckersState
    board = zeros(Position, (10, 10))

    for y in 1:4
        offset = 1+(y%2)
        for x in 0:4
            board[x*2 + offset, y] = Piece(2, false)
        end
    end

    for y in 7:10
        offset = 1+(y%2)
        for x in 0:4
            board[x*2 + offset, y] = Piece(1, false)
        end
    end

    return CheckersState(board, 1)
end

function Environments.make_step(s::CheckersState, a::Action) :: CheckersState end

function Environments.is_final_state(s::State) :: Bool end

function Environments.get_final_state_rewards(s::State) :: Array{Float64} end

function Environments.get_current_player(s::State) :: Int end

function Environments.action_space(s::State) :: Array{Action} end

function Environments.is_valid_action(s::State, a::Action) :: Bool end

function Environments.render(s::State)
    println(s)
end

function Environments.max_reward(s::State) :: Float64 end

function Environments.state_hash(s::State)::Array{Int64} end


end