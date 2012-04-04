# http://en.wikipedia.org/wiki/Multivariate_kernel_density_estimation#Density_estimation_in_R_with_a_full_bandwidth_matrix

values <- read.csv('himmelbrau_values.csv', header = FALSE)
names(values) <- c('x', 'y', 'v')

solutions <- read.csv('himmelbrau_solutions.csv', header = FALSE)
names(solutions) <- c('x', 'y')

# Show heatmap of function's value.
# Show points of solutions found by SA algorithm.
library('ggplot2')
ggplot(values, aes(x = x, y = y)) +
  geom_tile(aes(fill = log1p(v))) +
  geom_point(data = solutions, aes(x = x, y = y, color = 'red')) +
  opts(legend.position = 'none')
ggsave('himmelbrau.png')
