#PSYC 259 Homework 1 - Data Import
#For full credit, provide answers for at least 6/8 questions

#List names of students collaborating with (no more than 2): 
# NA (myself; Priscilla Whang)

#GENERAL INFO 
#data_A contains 12 files of data. 
#Each file (6192_3.txt) notes the participant (6192) and block number (3)
#The header contains metadata about the session
#The remaining rows contain 4 columns, one for each of 20 trials:
#trial_number, speed_actual, speed_response, correct
#Speed actual was whether the figure on the screen was actually moving faster/slower
#Speed response was what the participant report
#Correct is whether their response matched the actual speed

### QUESTION 1 ------ 

# clear console and environment
cat('\014')
rm(list = ls())

# Load the readr package

# ANSWER
library(readr)

# also loading a few more
library(here)   # need for relative path
library(dplyr)  # need for relocating cols
library(readxl) # need for QUESTION 8

### QUESTION 2 ----- 

# Read in the data for 6191_1.txt and store it to a variable called ds1
# Ignore the header information, and just import the 20 trials
# Be sure to look at the format of the file to determine what read_* function to use
# And what arguments might be needed

# ds1 should look like this:

# # A tibble: 20 × 4
#  trial_num    speed_actual speed_response correct
#   <dbl>       <chr>        <chr>          <lgl>  
#     1          fas          slower         FALSE  
#     2          fas          faster         TRUE   
#     3          fas          faster         TRUE   
#     4          fas          slower         FALSE  
#     5          fas          faster         TRUE   
#     6          slo          slower         TRUE   
# etc..

# A list of column names are provided to use:

col_names  <-  c("trial_num","speed_actual","speed_response","correct")

# ANSWER

# set relative file path
ds1 <- read_table(here('data_A', '6191_1.txt'),
                  col_names = col_names,
                  skip = 7)
ds1
# according to the 'read_table' documentation 
# (https://www.rdocumentation.org/packages/readr/versions/0.1.1/topics/read_table):
# skip argument = number of lines to skip before reading data

#MComment: If you're in the larger working directory (or a project repository), you can just use the below relative path without the here package - 
ds1 <- read_tsv("data_A/6191_1.txt", skip = 7, col_names = col_names)


### QUESTION 3 ----- 

# For some reason, the trial numbers for this experiment should start at 100
# Create a new column in ds1 that takes trial_num and adds 100
# Then write the new data to a CSV file in the "data_cleaned" folder

# ANSWER

# create new column
ds1$trial_num100 <- ds1$trial_num + 100

# relocate column
ds1 <- ds1 %>%
  relocate(trial_num100, .after = trial_num)

ds1

# create 'data_cleaned' folder
dir.create(here('data_cleaned'))

# write .csv
write_csv(ds1, here('data_cleaned', 'ds1_cleaned.csv'))

### QUESTION 4 ----- 

# Use list.files() to get a list of the full file names of everything in "data_A"
# Store it to a variable

# ANSWER
data_A_files <- list.files(here('data_A'), full.names = FALSE)
data_A_files

#MComment: Try putting the file names in quotes, it should work as well
data_A_files <- list.files("data_A", full.names = TRUE)

### QUESTION 5 ----- 

# Read all of the files in data_A into a single tibble called ds

# ANSWER
ds <- read_tsv(here('data_A', data_A_files),
               col_names = col_names,
               col_types = cols(
                 trial_num = col_integer(),
                 speed_actual = col_character(),
                 speed_response = col_character(),
                 correct = col_logical()
               ),
               skip = 7,
               id = 'filename') %>%
  mutate(filename = basename(filename))

ds # check: 240 obs. = 12 files x 20 trials

#Mcomment: once you make the data_A file, you can just call that on read_tsv
ds <- read_tsv(fnames, skip = 7, col_names = col_names)

### QUESTION 6 -----

# Try creating the "add 100" to the trial number variable again
# There's an error! Take a look at 6191_5.txt to see why.
# Use the col_types argument to force trial number to be an integer "i"
# You might need to check ?read_tsv to see what options to use for the columns
# trial_num should be integer, speed_actual and speed_response should be character, and correct should be logical
# After fixing it, create the column to add 100 to the trial numbers 
# (It should work now, but you'll see a warning because of the erroneous data point)

# ANSWER

# help !
?read_tsv

# please see above, QUESTION 5:
# added col_types

#MComment: Yup I noticed you had already fixed this! See another option below - 
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = "iccl")

# create new column
ds$trial_num100 <- ds$trial_num + 100

# relocate column
ds <- ds %>%
  relocate(trial_num100, .after = trial_num)

ds

### QUESTION 7 -----

# Now that the column type problem is fixed, take a look at ds
# We're missing some important information (which participant/block each set of trials comes from)
# Read the help file for read_tsv to use the "id" argument to capture that information in the file
# Re-import the data so that filename becomes a column

# ANSWER

# please see above, QUESTION 5:
# added id column and transformed to only grab file basename

#MComment: Yupp, looks good! I also have other code for pulling info from the file name below - 
library(tidyr)
ds <- ds %>% extract(filename, into = c("id","session"), "(\\d{4})_(\\d{1})") 
#Extract takes a character variable, names of where to put the extracted data,
# and then a regular expression saying what pattern to look for.
# each part in parentheses is one variable to extract
# \\d{4} means 4 digits, \\d{1} means 1 digit

# Or use "separate", which breaks everything by any delimiter (or a custom one)
# data_A/6191_1.txt will turn into:
# data   A   6191   1   txt
# if we only want to keep 6191 and 1, we can put NAs for the rest
ds <- ds %>% separate(filename, into = c(NA, NA, "id", "session", NA))

### QUESTION 8 -----

# Your PI emailed you an Excel file with the list of participant info 
# Install the readxl package, load it, and use it to read in the .xlsx data in data_B
# There are two sheets of data -- import each one into a new tibble

# ANSWER

participants <- read_excel(here('data_B', 'participant_info.xlsx'), sheet = 'participant')
testdates <- read_excel(here('data_B', 'participant_info.xlsx'), sheet = 'testdate')

participants
testdates

#Mcomment: Great! Only thing I'd recommend adding is column names for sheet 2 and using the relative path in ""
test_dates <- read_xlsx("data_B/participant_info.xlsx", col_names = c("participant", "test_date"), sheet = 2)
