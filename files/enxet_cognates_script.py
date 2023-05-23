###This is a script designed to look through a txt file and find all unique words with a specified character ##
### in this case the characters are /á, é, ó/, the long vowels of Enxet, as found in Elliott (2021) ###

## import the relevant stuff. I don't think that pandas ultimately ended up being needed
import pandas as pd 
import re
import csv


## set variables that are likely to be changed on subsequent iterations 

file_path = "C:/Users/wheel/Dropbox/PC/Desktop/A GRAMMAR OF ENXET SUR_Searchable"
output_csv = "cognates.csv" ###this names the output csv file, listed here so it is easily changeable 
fields = ['token', 'vowel'] ## these are the column headers in the csv 

#print(file_path) ## to check that it has worked properly 

###BEGIN SCRIPT 

with open(file_path, 'r', encoding ='utf-8') as f: ## important to specify encoding because this is not the default
	lines =str(f.readlines()) ## don't know if this is necessary but this i show i made it work in testing
	result =re.findall(r"\b[-aeoptckq'mngsxhlywáéó]*(á|é|ó)[-aeoptckq'mngsxhlywáéó]*(\b|\n)", lines)

		## this regex finds ALL occurrences of strings which have: left word boundary + zero or more letters of the enxet alphabet + either a/e/o, + another zero or more letters of the enxet alphabet + either a word boundary or a new line 

	result_unique =set(result) ## this turns the result list into a set, which eliminates all repeat tokens

	with open (output_csv, 'w') as csvfile: 
		csvwriter = csv.writer(csvfile) ## create a csv writer object. not sure why this is necessary but it works 
		csvwriter.writerow(fields) ## writes in the fields at the top of the csv 
		csvwriter.writerows(result_unique) ## writes in the result set 


## because both files are opened with 'with' managers, they are automatically closed
## this script must be in the same directory as the input and output
## i have not actually tested running it from command line--i ran it in a jupyter notebook, but wanted a clean version

###this part of the script reads in the output file and eliminates any duplicates--this is done separately because i manually removed all hyphens from the original output 

## set up the variables used in the rest of the script for easy access 

inputfile = "C:/Users/wheel/Dropbox/PC/Desktop/cognates_no segmentation.csv"
columname = 'token' ## this is the column you want it to look in to identify the duplicates
newoutput ="cognates_trimmed.csv" ## this output file has only 2 columns, the index, and the column looked through for duplicates. presumably there is a way to keep associated other columns, but I did not. 

 ## this bit does require pandas 
 df = pd.read_csv(inputfile, encoding = 'latin1', usecols = [columnname]).drop_duplicates(keep='first').reset_index() ## this is copied wholesale from a stack exchange

## write the df (dataframe) to a new csv 
 df.to_csv(newoutput, encoding ='latin1', index =False)