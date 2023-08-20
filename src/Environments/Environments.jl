module Environments
export State, Action, initial_state, make_step, is_final_state, get_final_state_rewards, action_space, is_valid_action, render, get_current_player, max_reward

include("BaseEnv.jl")
include("TicTacToe.jl")
include("Connect4.jl")

using .TicTacToe
using .Connect4

methods(action_space)

end