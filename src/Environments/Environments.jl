module Environments
export State, Action, initial_state, make_step, is_final_state, get_final_state_rewards, 
            action_space, is_valid_action, render, get_current_player, max_reward, state_hash

include("BaseEnv.jl")
include("TicTacToe.jl")
include("Connect4.jl")
include("TestEnv.jl")
include("Connect3.jl")
include("Connect4Efficient.jl")

using .TicTacToe
using .Connect4
using .TestEnv
using .Connect3
using .Connect4Efficient


end