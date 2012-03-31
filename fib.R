fib <- function(n)
{
  ifelse(n < 2, n, fib(n - 1) + fib(n - 2))
}

start <- Sys.time()
fib(25)
end <- Sys.time()
end - start
