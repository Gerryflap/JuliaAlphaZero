module AlphaZero
export run

include("Environments/Environments.jl")
include("Agents/Agents.jl")

using .Environments
import .Environments.TicTacToe
import .Environments.Connect4
using .Agents
import .Agents.RandomAgent
import .Agents.PerfectAgent
import .Agents.AlphaBetaPerfectAgent
import .Agents.SimpleMctsAgent


function run() 
    # agents = [AlphaBetaPerfectAgent.AbpAgentState(), PerfectAgent.PerfectAgentState()]
    agents = [SimpleMctsAgent.MctsAgentState(200), SimpleMctsAgent.MctsAgentState(1000)]
    state = initial_state(Connect4.C4State)
    render(state)
    while !is_final_state(state)
        current_agent = agents[get_current_player(state)]
        a :: Action = choose_action(current_agent, state)
        state = make_step(state, a)
        render(state)
    end

    println("Game end, rewards = $(get_final_state_rewards(state))")
    
end

end # module AlphaZero

AlphaZero.run()