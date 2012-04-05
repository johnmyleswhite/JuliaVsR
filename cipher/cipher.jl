# This file runs if fed in line by line to interpreter.
# It does not run if executed in batch mode.
# Not clear to my why that is.

# Need to fix sample to return scalar iff n == 1.

function sample(a, n)
	o = []
	
	for i = 1:n
		index = ceil(length(a) * rand())
		o = [o, a[index]]
	end
	
	o
end

function keys(h)
	h_keys = []
	
	for e = h
		h_keys = [h_keys, e[1]]
	end
	
	h_keys
end

english_letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
                   'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
                   'w', 'x', 'y', 'z']

caesar_cipher = HashTable()

inverse_caesar_cipher = HashTable()

for index = 1:length(english_letters)
  caesar_cipher[english_letters[index]] = english_letters[mod(index, 26) + 1]
  inverse_caesar_cipher[english_letters[mod(index, 26) + 1]] = english_letters[index]
end

println(caesar_cipher)
println(inverse_caesar_cipher)

function apply_cipher_to_string(s, cipher)
  output = ""
  
  for c = s
    output = strcat(output, cipher[c])
  end
  
  output
end

function apply_cipher_to_text(text, cipher)
  output = []
  
  for s = text
    output = [output, apply_cipher_to_string(s, cipher)]
  end
  
  output
end

println(apply_cipher_to_text(["sample", "text"], caesar_cipher))

function generate_random_cipher()
  cipher = HashTable()
  
  inputs = english_letters
  
  outputs = english_letters[sample(1:length(english_letters), length(english_letters))]
  
  for index = 1:length(english_letters)
    cipher[inputs[index]] = outputs[index]
  end
  
  cipher
end

function key_contains(h, v)
  for test_v = h
    if test_v[2] == v
      return test_v[1]
    end
  end
  return false
end

print(key_contains({'a' => 1, 'b' => 2}, 1))
print(key_contains({'a' => 1, 'b' => 2}, 2))
print(key_contains({'a' => 1, 'b' => 2}, 3))

function hash_copy(h)
  c = HashTable()
  
  for k = keys(h)
    c[k] = copy(h[k])
  end
  
  c
end

function modify_cipher(cipher, k, v)
  new_cipher = hash_copy(cipher)
  
  new_cipher[k] = v
  
  old_v = cipher[k]
  
  collateral_input = key_contains(cipher, v)
  
  new_cipher[collateral_input] = old_v
  
  new_cipher
end

println(modify_cipher(caesar_cipher, 'a', 'c'))

function propose_modified_cipher(cipher, english_letters)
  k = sample(keys(cipher), 1)[1]
  
  v = sample(english_letters, 1)[1]
  
  modify_cipher(cipher, k, v)
end

# csvread() needs to account for header and understand how strings can be quoted.
lexical_data = csvread("lexical_database.csv")
lexical_database = HashTable()
for i = 1:size(lexical_data, 1)
  lexical_database[lexical_data[i, 1]] = lexical_data[i, 2]
end

println(lexical_database["a"])
println(lexical_database["the"])
println(lexical_database["he"])
println(lexical_database["she"])
println(lexical_database["data"])

function one_gram_probability(one_gram, lexical_database)
  lexical_probability = eps()
  
  if has(lexical_database, one_gram)
    lexical_probability = lexical_database[one_gram]
  end
  
  lexical_probability
end

function log_probability_of_text(text, cipher, lexical_database)
  log_probability = 0.0
  
  for s = text
    decrypted_string = apply_cipher_to_string(s, cipher)
    log_probability = log_probability + log(one_gram_probability(decrypted_string, lexical_database))
  end
  
  log_probability
end

log_probability_of_text(apply_cipher_to_text(["sample", "text"], caesar_cipher),
                        inverse_caesar_cipher,
                        lexical_database)

log_probability_of_text(apply_cipher_to_text(["sample", "text"], caesar_cipher),
                        caesar_cipher,
                        lexical_database)

function metropolis_step(text, cipher, lexical_database)
  proposed_cipher = propose_modified_cipher(cipher, english_letters)
  
  lp1 = log_probability_of_text(text, cipher, lexical_database)
  lp2 = log_probability_of_text(text, proposed_cipher, lexical_database)
  
  if (lp2 > lp1)
    return(proposed_cipher)
  else
    a = exp(lp2 - lp1)
    x = rand()
    
    if (x < a)
      return(proposed_cipher)
    else
      return(cipher)
    end
  end
end

decrypted_text = split("here is some sample text")

encrypted_text = apply_cipher_to_text(decrypted_text, caesar_cipher)

srand(1)

cipher = generate_random_cipher()

number_of_iterations = 50000

results = Array(Any, number_of_iterations, 4)

@elapsed for iteration = 1:number_of_iterations
  log_probability = log_probability_of_text(encrypted_text,
                                            cipher,
                                            lexical_database)
  
  current_decrypted_text = join(apply_cipher_to_text(encrypted_text, cipher), ' ')
  
  correct_text = int64(current_decrypted_text == join(decrypted_text, ' '))
  
  results[iteration, 1] = iteration
  results[iteration, 2] = log_probability
  results[iteration, 3] = current_decrypted_text
  results[iteration, 4] = correct_text
  
  cipher = metropolis_step(encrypted_text, cipher, lexical_database)
end

csvwrite("julia_results.csv", results)
