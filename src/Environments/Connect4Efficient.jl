module Connect4Efficient
export C4eState, C4eAction, initial_state, make_step, is_final_state, get_final_state_rewards, action_space, is_valid_action, render, get_current_player

using Formatting
using Match
import ..Environments

struct C4eAction <: Environments.Action
    x :: Int
    player :: Int
end

struct ByteBoard
    # Whether there is a stone
    mask :: Int64
    # Player to whom the stone belongs
    board :: Int64
end

struct C4eState <: Environments.State
    board :: ByteBoard
    player :: Int
    # Used for more efficient win condition checking
    last_action :: Union{C4eAction,Nothing}
end

function Environments.initial_state(::Type{C4eState}) :: C4eState
    return C4eState(ByteBoard(0,0), 1, nothing)
end

function drop_stone(board::ByteBoard, col :: Int, player :: Int) :: ByteBoard
    # From bottom up, find the first empty slot and put the player token there
    height = 6
    for row in 1:6 
        if isnothing(get_player_at(board, col, row))
            height = row - 1
            break
        end
    end

    if height == 6
        throw(OutOfBoardBoundException("Cannot drop stone in full column!"))
    end

    row = height + 1

    new_mask = board.mask
    # Set the bit in the mask to 1
    new_mask = new_mask | (1 :: Int64 << to_shift_amnt(col, row))

    # Set the value in the board (note: this assumes that the value was previously unset and thus 0, 
    #   it won't overwrite 1 with 0, only 0 with 1 if the player == 2)
    new_board = board.board | (player :: Int64 - 1) << to_shift_amnt(col, row)
    return ByteBoard(new_mask, new_board)
end

function Environments.make_step(s::C4eState, a::C4eAction) :: C4eState
    if (!Environments.is_valid_action(s, a))
        throw(Environments.InvalidActionException())
    end
    board = s.board
    player = s.player

    board = drop_stone(board, a.x, player)
    player = (a.player) % 2 + 1
    return Environments.C4eState(board, player, a)
end

function get_winner_and_final_state(s::C4eState) :: Tuple{Bool, Int}
    if s.last_action === nothing
        return false, 0
    end

    board = s.board

    # Check for rows
    row_mask :: Int64 = 0b000001_000001_000001_000001

    for col in 1:4
        for row in 1:6
            shifted_row_mask :: Int64 = row_mask << to_shift_amnt(col, row)
            done, winner = get_winner_from_mask(board, shifted_row_mask)
            if done
                return true, winner
            end
        end
    end

    # Check for columns
    col_mask :: Int64 = 0b001111
    for row in 1:3
        shifted_col_mask :: Int64 = col_mask << to_shift_amnt(s.last_action.x, row)
        done, winner = get_winner_from_mask(board, shifted_col_mask)
        if done
            return true, winner
        end
    end

    diag_mask_1 :: Int64 = 0b001000_000100_000010_000001
    diag_mask_2 :: Int64 = 0b000001_000010_000100_001000
    for x in 1:4
        for y in 1:3
            done, winner = get_winner_from_mask(board, diag_mask_1 << to_shift_amnt(x, y))
            if done
                return true, winner
            end

            done, winner = get_winner_from_mask(board, diag_mask_2 << to_shift_amnt(x, y))
            if done
                return true, winner
            end
        end
    end

    all_one :: Int64 = 0b111111_111111_111111_111111_111111_111111_111111
    if all_one & s.board.mask == all_one
        return true, 0
    end

    return false, 0
end

function get_winner_from_mask(board::ByteBoard, mask::Int64)
    if mask == 0
        throw(OutOfBoardBoundException("Cannot be 0!"))
    end
    masked_mask = board.mask & mask
    # If all values are 1 (i.e. all columns are filled at this row), the 2 values are the same
    all_filled = masked_mask == mask
    if all_filled
        player_vals = board.board & mask
        
        # All 0, player 1 has all the cells
        if player_vals == 0
            # println("All 0 for mask " * bitstring(mask) * ", board.mask " * bitstring(board.mask) * " and board " * bitstring(board.board))
            return true, 1
        end
        
        # All 1, player 2 has all the cells
        if player_vals == mask
            # println("All 1 for mask " * bitstring(mask) * ", board.mask " * bitstring(board.mask) * " and board " * bitstring(board.board))
            return true, 2
        end
    end
    return false, 0
end

function Environments.is_final_state(s::C4eState) :: Bool
    result, _ = get_winner_and_final_state(s)
    return result
end

function Environments.get_final_state_rewards(s::C4eState) :: Array{Float64}
    _, winner = get_winner_and_final_state(s)
    return @match winner begin
        0 => [ 0.0  0.0]     # Draw
        1 => [ 1.0 -1.0]    # P1 win
        2 => [-1.0  1.0]
    end
end

function Environments.get_current_player(s::C4eState) :: Int
    return s.player
end


function Environments.action_space(s::C4eState) :: Array{C4eAction}
    actions = []
    for x in 1:7
        if isnothing(get_player_at(s.board, x, 6))
            push!(actions, C4eAction(x, s.player))
        end
    end
    return actions
end

function Environments.is_valid_action(s::C4eState, a::C4eAction) :: Bool
    return isnothing(get_player_at(s.board, a.x, 6)) && a.player == s.player
end

function Environments.render(s::C4eState)
    str = ""
    for y in 6:-1:1
        for x in 1:7
            str *= "|"
            str *= @match get_player_at(s.board, x, y) begin
                1 => "X"
                2 => "O"
                nothing => "_"
            end
        end
        str *= "|\n"
    end
    println(str)
end

function Environments.max_reward(s::C4eState) :: Float64
    return 1.0
end

function Environments.state_hash(s::C4eState)::Array{Int64}
    result = zeros(Int64, (3,))
    result[1] = s.board.mask
    result[2] = s.board.board
    result[3] = s.player
    return result
end

function get_player_at(board::ByteBoard, col::Int, row::Int) :: Union{Int, Nothing}
    if col < 1 || col > 7 || row > 6 || row < 1
        throw(OutOfBoardBoundException(format("Column {1:d} or row {2:d} is out of bounds", col, row)))
    end

    if (board.mask >> to_shift_amnt(col, row) & 1) == 0
        return nothing
    end

    # Shift the board int so the desired bit is the least significant (aka rightmost) bit
    shifted = board.board >> to_shift_amnt(col, row)
    # Mask with 1, so all other higher bits are discarded
    masked = shifted & 1
    # Add one, because player is either 1 or 2 instead of 0 or 1
    player = masked + 1

    return player
end

function to_shift_amnt(col :: Int, row :: Int)
    return (6 * (col - 1) + (row - 1))
end

struct OutOfBoardBoundException <: Exception 
    message :: String
end

end