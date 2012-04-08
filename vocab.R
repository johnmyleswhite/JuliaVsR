vocab <- read.csv('vocab.csv')
library('R2HTML')
HTML(vocab,
	 file = 'vocab.html',
	 align = "center",
	 digits = 2,
	 decimal.mark = ",",
	 row.names = FALSE)
# Post-process to escape ampersands, remove HTML cruft and tidy HTML.
