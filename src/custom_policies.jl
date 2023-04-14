using StatsBase

### This file defines custom policies.###

### PriorityPolicy ###
```If the action contains a "priority" field, use that. Otherwise, use the index.```
mutable struct PriorityPolicy{RNG<:AbstractRNG, P<:Union{POMDP,MDP}} <: Policy
    rng::RNG
    problem::P
end
# The constructor below should be used to create the policy so that the action space is initialized correctly
PriorityPolicy(problem::Union{POMDP,MDP};
             rng=Random.GLOBAL_RNG) = PriorityPolicy(rng, problem)

## policy execution ##
function POMDPs.action(policy::PriorityPolicy, s)
    as = actions(policy.problem, s)
    if hasproperty(as[1], :priority)
        weights = [a.priority for a in as]
    else
        weights = [(length(as) - i + 1)^5 for (i, a) in enumerate(as)]
    end
    a = wsample(policy.rng, as, weights)
    return a
end

function POMDPs.action(policy::PriorityPolicy, b::Nothing)
    return rand(policy.rng, actions(policy.problem))
end

## convenience functions ##
POMDPs.updater(policy::PriorityPolicy) = policy.updater

mutable struct PrioritySolver <: Solver
    rng::AbstractRNG
end
PrioritySolver(;rng=Random.GLOBAL_RNG) = PrioritySolver(rng)
POMDPs.solve(solver::PrioritySolver, problem::Union{POMDP,MDP}) = PriorityPolicy(solver.rng, problem)



### PickFirstPolicy ###
```Always pick the first action.```
mutable struct PickFirstPolicy{RNG<:AbstractRNG, P<:Union{POMDP,MDP}} <: Policy
    rng::RNG
    problem::P
end
# The constructor below should be used to create the policy so that the action space is initialized correctly
PickFirstPolicy(problem::Union{POMDP,MDP};
             rng=Random.GLOBAL_RNG) = PickFirstPolicy(rng, problem)

## policy execution ##
function POMDPs.action(policy::PickFirstPolicy, s)
    return actions(policy.problem, s)[1]
end

function POMDPs.action(policy::PickFirstPolicy, b::Nothing)
    return actions(policy.problem)[1]
end

## convenience functions ##
POMDPs.updater(policy::PickFirstPolicy) = policy.updater

mutable struct PickFirstSolver <: Solver
    rng::AbstractRNG
end
PickFirstSolver(;rng=Random.GLOBAL_RNG) = PickFirstSolver(rng)
POMDPs.solve(solver::PickFirstSolver, problem::Union{POMDP,MDP}) = PickFirstPolicy(solver.rng, problem)



### IteratePolicy ###
```Iterate over all actions.```
mutable struct IteratePolicy{RNG<:AbstractRNG, P<:Union{POMDP,MDP}} <: Policy
    rng::RNG
    problem::P
    i::Int64
end
# The constructor below should be used to create the policy so that the action space is initialized correctly
IteratePolicy(problem::Union{POMDP,MDP}, i::Int64;
             rng=Random.GLOBAL_RNG) = IteratePolicy(rng, problem, i)

## policy execution ##
function POMDPs.action(policy::IteratePolicy, s)
    all_actions = actions(policy.problem, s)
    a = all_actions[mod(policy.i, length(all_actions))]
    policy.i += 1
    return a
end

function POMDPs.action(policy::IteratePolicy, b::Nothing)
    all_actions = actions(policy.problem)
    a = all_actions[mod(policy.i, length(all_actions))]
    policy.i += 1
    return a
end

## convenience functions ##
POMDPs.updater(policy::IteratePolicy) = policy.updater

mutable struct IterateSolver <: Solver
    i::Int64
    rng::AbstractRNG
end
IterateSolver(i::Int64;rng=Random.GLOBAL_RNG) = IterateSolver(i, rng)
POMDPs.solve(solver::IterateSolver, problem::Union{POMDP,MDP}) = IteratePolicy(solver.rng, problem, solver.i)


