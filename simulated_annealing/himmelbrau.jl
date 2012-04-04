# http://en.wikipedia.org/wiki/Himmelblau%27s_function

function himmelbrau(x, y)
  (x^2 + y - 11)^2 + (x + y^2 - 7)^2
end

# Minima
@assert abs(himmelbrau(3, 2) - 0) < 0.01
@assert abs(himmelbrau(-2.805118, 3.131312) - 0) < 0.01
@assert abs(himmelbrau(-3.779310, -3.283186) - 0) < 0.01
@assert abs(himmelbrau(3.584428, -1.848126) - 0) < 0.01

# Maxima
@assert abs(himmelbrau(-0.270845, -0.923089) - 181.617) < 0.01

# Evaluate function over a grid.
load("../utils.jl")

grid = sequence(-4, 4, 0.1)

values = zeros(length(grid)^2, 3)

i = 1

for x = grid
  for y = grid
    v = himmelbrau(x, y)
    values[i, 1:3] = [x, y, v]
    i = i + 1
  end
end

csvwrite("himmelbrau_values.csv", values)

# Find solutions using SA.
load("simulated_annealing.jl")
load("../rng.jl")

#function neighbors(z)
#  [rand_uniform(-10, 10), rand_uniform(-10, 10)]
#end

function neighbors(z)
  [rand_uniform(z[1] - 1, z[1] + 1), rand_uniform(z[2] - 1, z[2] + 1)]
end

srand(1)

n = 5000

solutions = zeros(n, 2)

for i = 1:n
  solution = simulated_annealing(z -> himmelbrau(z[1], z[2]),
                                 [0, 0],
                                 neighbors,
                                 log_temperature,
                                 10000,
                                 true,
                                 false)
  solutions[i, :] = solution
end

csvwrite("himmelbrau_solutions.csv", solutions)
