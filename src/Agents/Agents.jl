module Agents
    export choose_action
    include("BaseAgent.jl")
    include("RandomAgent.jl")
    include("PerfectAgent.jl")
    include("AlphaBetaPerfectAgent.jl")
    include("SimpleMctsAgent.jl")
    include("HumanAgent.jl")


    import .RandomAgent
    import .PerfectAgent
    import .AlphaBetaPerfectAgent
    import .SimpleMctsAgent
    import .HumanAgent
end