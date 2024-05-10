using Pkg
Pkg.activate(".")
using CairoMakie
#using GLMakie
using Agents
using Statistics: mean

# This is a model of agents that simulate a SIRS model

@agent struct Person(GridAgent{2})
    state::Int  # 0 = S, 1 = I, 2 = R
    next_state::Int
end

function sir_step!(agent, model)
    if agent.state == 1
        # infect neighbors
        neighbors = nearby_agents(agent, model, 1)
        for neighbor in neighbors
            # rand() is uniformly distributed between 0 and 1
            if rand() < model.infection_probability
                neighbor.next_state = 1
            end
        end
        # recover
    end


end

function sir_update!(model)
    for agent in allagents(model)
        agent.state = agent.next_state
    end
end


function initialize_model(;agent_count = 1, infection_probability = 0.1, recovery_probability = 0.1, max_steps = 100)

    # generate a space
    space = GridSpaceSingle((10, 10), periodic=true)
    
    properties = Dict(
        :infection_probability => infection_probability,
        :recovery_probability => recovery_probability,
        :max_steps => max_steps
    )

    # generate a model
    model = ABM(Person, space, properties=properties, agent_step! = sir_step!, model_step! = sir_update!)

    # add agents that are healthy
    for i in 1:agent_count
        agent = Person(i, (0,0), 0, 0)
        add_agent_single!(agent, model)
    end

    case_zero = random_agent(model)
    case_zero.state = 1
    case_zero.next_state = 1
    return model
end





function acolor(agent)
    if agent.state == 1
        return :red
    end
   
    return :black
end






function isill(agent)
    if (agent.state == 1)
        return true
    end
    return false
end

isill(model[10])

function ill90(model, time)
    if time > model.max_steps
        return true
    end

    illagents = count(isill, allagents(model))
    return illagents/nagents(model) ≥ 0.9
end

 # ill90(model, time) = count(a -> a.state == 1, allagents(model))/nagents(model) ≥ 0.9



 model = initialize_model(;agent_count = 120, recovery_probability = 0.1, infection_probability = 0.0)


 fig, _, _ = abmplot(model; agent_color = acolor)
 fig
 
 adata = [(:state, mean), (:state, sum)]
 
 
 adf, mdf = run!(model, ill90; adata)
 