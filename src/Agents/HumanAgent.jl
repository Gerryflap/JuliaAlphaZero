module HumanAgent

export choose_action, HumanAgentState
import ..Agents
using ...Environments
using Formatting

struct HumanAgentState <: Agents.AgentState end

function Agents.choose_action(agentState::HumanAgentState, s::State) :: Action
    actions = action_space(s)
    action = nothing

    while isnothing(action)
        println("Choose an action: ")
        for (i, action) in enumerate(actions)
            printfmt("{}) {}\n", i, action)
        end
        
        response = chomp(readline())
        index = -1
        try
            index = parse(Int64, response)
        catch
            index = -1
        end

        if index > 0 && index <= length(actions) 
            action = actions[index]
        else
            print("Invalid input, try again and enter a valid number!")
        end
    end
    return action

end
end