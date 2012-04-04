function log_temperature(i)
  1 / log(i)
end

function constant_temperature(i)
  0.1
end

# simulated_annealing
# Arguments:
# * cost: Function from states to the real numbers. Often called an energy function, but this algorithm works for both positive and negative costs.
# * s0: The initial state of the system.
# * neighbor: Function from states to states. Produces what the Metropolis algorithm would call a proposal.
# * temperature: Function specifying the temperature at time i.
# * iterations: How many iterations of the algorithm should be run? This is the only termination condition.
# * keep_best: Do we return the best state visited or the last state visisted? (Should default to true.)
# * trace: Do we show a trace of the system's evolution?

function simulated_annealing(cost,
                             s0,
                             neighbor,
                             temperature,
                             iterations,
                             keep_best,
                             trace)
                             
  # Set our current state to the specified intial state.
  s = s0

  # Set the best state we've seen to the intial state.
  best_s = s0

  # We always perform a fixed number of iterations.
  for i = 1:iterations
    t = temperature(i)
    s_n = neighbor(s)
    if trace println("$i: s = $s") end
    if trace println("$i: s_n = $s_n") end
    y = cost(s)
    y_n = cost(s_n)
    if trace println("$i: y = $y") end
    if trace println("$i: y_n = $y_n") end
    if y_n <= y
      s = s_n
      if trace println("Accepted") end
    else
      p = exp(- ((y_n - y) / t))
      if trace println("$i: p = $p") end
      if rand() <= p
        s = s_n
        if trace println("Accepted") end
      else
        s = s
        if trace println("Rejected") end
      end
    end
    if trace println() end
    if cost(s) < cost(best_s)
      best_s = s
    end
  end
  
  if keep_best
    best_s
  else
    s
  end
end
