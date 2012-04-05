english.letters <- c('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
                     'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
                     'w', 'x', 'y', 'z')

caesar.cipher <- list()

inverse.caesar.cipher <- list()

for (index in 1:length(english.letters))
{
  caesar.cipher[[english.letters[index]]] <- english.letters[index %% 26 + 1]
  inverse.caesar.cipher[[english.letters[index %% 26 + 1]]] <- english.letters[index]
}

print(caesar.cipher)
print(inverse.caesar.cipher)

apply.cipher.to.string <- function(string, cipher)
{
  output <- ''

  for (i in 1:nchar(string))
  {
  output <- paste(output, cipher[[substr(string, i, i)]], sep = '')
  }
  
  return(output)
}

apply.cipher.to.text <- function(text, cipher)
{
  output <- c()
  
  for (string in text)
  {
    output <- c(output, apply.cipher.to.string(string, cipher))
  }
  
  return(output)
}

print(apply.cipher.to.text(c('sample', 'text'), caesar.cipher))

generate.random.cipher <- function()
{
  cipher <- list()
  
  inputs <- english.letters
  
  outputs <- english.letters[sample(1:length(english.letters), length(english.letters))]
  
  for (index in 1:length(english.letters))
  {
    cipher[[inputs[index]]] <- outputs[index]
  }
  
  return(cipher)
}

modify.cipher <- function(cipher, input, output)
{
  new.cipher <- cipher
  
  new.cipher[[input]] <- output
  
  old.output <- cipher[[input]]
  
  collateral.input <- names(which(sapply(names(cipher),
                                         function (key) {cipher[[key]]}) == output))
  
  new.cipher[[collateral.input]] <- old.output
  
  return(new.cipher)
}

propose.modified.cipher <- function(cipher)
{
  input <- sample(names(cipher), 1)
  
  output <- sample(english.letters, 1)
  
  return(modify.cipher(cipher, input, output))
}

load('lexical_database.Rdata')

print(lexical.database[['a']])
print(lexical.database[['the']])
print(lexical.database[['he']])
print(lexical.database[['she']])
print(lexical.database[['data']])

one.gram.probability <- function(one.gram, lexical.database = list())
{
  lexical.probability <- lexical.database[[one.gram]]
  
  if (is.null(lexical.probability) || is.na(lexical.probability))
  {
  return(.Machine$double.eps)
  }
  else
  {
  return(lexical.probability)
  }
}

log.probability.of.text <- function(text, cipher, lexical.database = list())
{
  log.probability <- 0.0
  
  for (string in text)
  {
    decrypted.string <- apply.cipher.to.string(string, cipher)
    log.probability <- log.probability +
    log(one.gram.probability(decrypted.string, lexical.database))
  }
  
  return(log.probability)
}

log.probability.of.text(apply.cipher.to.text(c("sample", "text"), caesar.cipher),
                        inverse.caesar.cipher,
                        lexical.database)

log.probability.of.text(apply.cipher.to.text(c("sample", "text"), caesar.cipher),
                        caesar.cipher,
                        lexical.database)

metropolis.step <- function(text, cipher, lexical.database = list())
{
  proposed.cipher <- propose.modified.cipher(cipher)
  
  lp1 <- log.probability.of.text(text, cipher, lexical.database)
  lp2 <- log.probability.of.text(text, proposed.cipher, lexical.database)
  
  if (lp2 > lp1)
  {
    return(proposed.cipher)
  }
  else
  {
    a <- exp(lp2 - lp1)
    x <- runif(1)
    
    if (x < a)
    {
      return(proposed.cipher)
    }
    else
    {
      return(cipher)
    }
  }
}

decrypted.text <- c('here', 'is', 'some', 'sample', 'text')

encrypted.text <- apply.cipher.to.text(decrypted.text, caesar.cipher)

set.seed(1)

cipher <- generate.random.cipher()

number.of.iterations <- 50000

results <- data.frame()

start.time <- Sys.time()

for (iteration in 1:number.of.iterations)
{
  log.probability <- log.probability.of.text(encrypted.text,
                                             cipher,
                                             lexical.database)
  
  current.decrypted.text <- paste(apply.cipher.to.text(encrypted.text,
                                                       cipher),
                                  collapse = ' ')
  
  correct.text <- as.numeric(current.decrypted.text == paste(decrypted.text,
                                                             collapse = ' '))

  results <- rbind(results,
                   data.frame(Iteration = iteration,
                              LogProbability = log.probability,
                              CurrentDecryptedText = current.decrypted.text,
                              CorrectText = correct.text))
  
  cipher <- metropolis.step(encrypted.text, cipher, lexical.database)
}

end.time <- Sys.time()

print(end.time - start.time)

write.table(results,
            file = file.path('r_results.tsv'),
            row.names = FALSE,
            sep = '\t')
