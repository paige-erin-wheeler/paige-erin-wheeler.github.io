#########################
# This is a script to measure the duration of of every
# vowel interval in the corresponding
# textgrid, for every wav file in a directory.
# Results are written into a spreadsheet
# Things that may need to change: 
# File locations (mine are very specified for me)
# which tier to get info from!

clearinfo


# Set up the working directory
# for relative path names

wd$ = homeDirectory$ + "/Desktop/Enenlhet/"

inDir$ = wd$ + "input_all/"
inDirWavs$ = inDir$ + "*.wav"
outDir$ = wd$ + "output_20221018/"	


# Set up variables to be used

sep$ = tab$
outFile$ = outDir$ + "enenlhet-duration_20220902.csv"
tierNum = 2
wordTier = 4


# Start the results table.. If you would like to get rid of some of the rows you have to MOVE THEM
#to somewhere outside of the row and not simply comment them out inline 

header$ = "fileName" + sep$ 
	...+ "intervalNumber" + sep$
	...+ "startTime" + sep$
	... + "vowelLabel" + sep$ 
	... + "wordLabel" + sep$
	... + "duration" + newline$

createDirectory: outDir$

if fileReadable: outFile$
	pauseScript: "Data spreadsheet already exists, overwrite?"
endif	
deleteFile: outFile$

writeFile: outFile$, header$


# Create the string with all of the wav files

relFiles = Create Strings as file list: "relFiles", inDirWavs$

selectObject: "Strings relFiles"


# How many wav files?

numFiles = Get number of strings
numFiles$ = string$: numFiles

appendInfoLine: "There are " + numFiles$ 
	... + " .wav files in this folder"


# Loop: this first one is going through each wav file in the folder 

for x from 1 to numFiles

	selectObject: relFiles

	# We want it to find the corresponding textgrid
	# The textgrid file will be named like the wav

	textgridName$ = Get string: x 

	appendInfoLine: "wav file " + textgridName$

	# Its path will end in .TextGrid though

	textgridxPath$ = inDir$ + textgridName$ - ".wav" + "_zc.TextGrid"
	#appendInfoLine: textgridxPath$ 

	# sound path for the .wav file 
	soundPath$ = inDir$ + textgridName$
	#appendInfoLine: soundPath$ 

	### Read the textgrid file 
	if fileReadable: textgridxPath$
			textgridx = Read from file: textgridxPath$	

			# So we have a textgrid opened that we want info from
			# How many intervals does the relevant tier (segment) have?
			numInt = Get number of intervals: tierNum
			#appendInfoLine: numInt 

			#How many intervals does the word tier have? 
			#numIntWord = Get number of intervals: wordTier
			#appendInfoLine: numIntWord

			# Let's loop through all of these intervals
			# and find the ones that contain an annotation that begins with a e o 

			for i from 1 to numInt
			selectObject: "TextGrid " + textgridName$ - ".wav" + "_zc"
			# intLabel will be the label of the interval
			intLabel$ = Get label of interval: tierNum, i
				if index_regex: intLabel$, "^[aeo]" 
						intStart = Get start time of interval: tierNum, i 
						intEnd = Get end time of interval: tierNum, i
						intDur = intEnd - intStart
						intDur$ = string$: intDur
						intMid = intStart + (intDur / 3)  
						intWordNum = Get interval at time: wordTier, intMid
						intWord$ = Get label of interval: wordTier, intWordNum 
						i$ = string$: i
						intStart$ = string$: intStart 

						dataRow$ = textgridName$ + sep$ 
						  ...+ i$ + sep$
						  ...+ intStart$ + sep$
						  ...+ intLabel$ + sep$ 
						  ...+ intWord$ + sep$
						  ...+ intDur$ + newline$

					  	appendFile: outFile$, dataRow$ 	
				endif   
			endfor

			#else appendInfoLine: "This sound file has no corresponding textgrid"
			
		# this here if is the one for "if the file exists"
		endif

	 selectObject:  "TextGrid " + textgridName$ - ".wav" + "_zc"
	 
	 Remove

	# this for closes off the "for all textgrid files"
endfor

selectObject: "Strings relFiles"

Remove

pauseScript: "All done!"

