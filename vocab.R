vocab <- read.csv('vocab.csv')
library('R2HTML')
HTML(vocab,
	 file = 'vocab.html',
	 align = "center",
	 digits = 2,
	 decimal.mark = ",",
	 row.names = FALSE)
# Post-process to escape ampersands, remove HTML cruft and tidy HTML.

# Add table to the README.md so things render directly to Github page
library(ascii)

base.readme <- "Pieces of code that can be used to compare Julia and R side-by-side for speed and interpretability."

# Generate Markdown for table
vocab.md <- capture.output(print(ascii(vocab[2:nrow(vocab),], include.rownames=F)))
vocab.md <- paste(vocab.md, collapse="\n")

readme.file <- file('README.md', open="w")
writeLines(vocab.md, readme.file)
close(readme.file)


