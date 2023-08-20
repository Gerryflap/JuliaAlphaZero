module Agents
    export RandomAgent, PerfectAgent, AlphaBetaPerfectAgent
    include("RandomAgent.jl")
    include("PerfectAgent.jl")
    include("AlphaBetaPerfectAgent.jl")

    import .RandomAgent
    import .PerfectAgent
    import .AlphaBetaPerfectAgent
end