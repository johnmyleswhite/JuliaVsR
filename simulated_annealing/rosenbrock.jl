#http://en.wikipedia.org/wiki/Rosenbrock_function

function rosenbrock(x, y)
  (1 - x)^2 + 100(y - x^2)^2
end

# Minima
@assert abs(rosenbrock(1, 1) - 0) < 0.01

# Evaluate function over a grid.
load("../utils.jl")

grid = sequence(-4, 4, 0.1)

values = zeros(length(grid)^2, 3)

i = 1

for x = grid
  for y = grid
    v = rosenbrock(x, y)
    values[i, 1:3] = [x, y, v]
    i = i + 1
  end
end

csvwrite("rosenbrock_values.csv", values)

# Find solutions using SA.
load("simulated_annealing.jl")
load("../rng.jl")

function neighbors(z)
  [rand_uniform(z[1] - 1, z[1] + 1), rand_uniform(z[2] - 1, z[2] + 1)]
end

srand(1)

n = 5000

solutions = zeros(n, 2)

for i = 1:n
  solution = simulated_annealing(z -> rosenbrock(z[1], z[2]),
                                 [0, 0],
                                 neighbors,
                                 log_temperature,
                                 10000,
                                 true,
                                 false)
  solutions[i, :] = solution
end

csvwrite("rosenbrock_solutions.csv", solutions)
