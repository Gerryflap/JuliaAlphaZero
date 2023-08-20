module AlphaZero
export run

include("Environments/Environments.jl")
include("Agents/Agents.jl")

using .Environments
import .Environments.Connect4
using .Agents


function run() 
    agents = [RandomAgent, AlphaBetaPerfectAgent]
    state :: Connect4.C4State = initial_state()
    render(state)
    while !is_final_state(state)
        current_agent = agents[get_current_player(state)]
        a :: Connect4.C4Action = current_agent.choose_action(state)
        state = make_step(state, a)
        render(state)
    end

    println("Game end, rewards = $(get_final_state_rewards(state))")
    
end

end # module AlphaZero

AlphaZero.run()