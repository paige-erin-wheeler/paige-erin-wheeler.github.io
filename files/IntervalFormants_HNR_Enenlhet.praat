
## this script will measure F1 and F2 of all vowel intevals (a,e,o) in a segmented text grid 
## it allows you to specify whether your speakers are male or female, and sets the formant settings appropriately 
## it will also collect the label of the word that the vowel appears in from another tier as well as the start time of the vowel 
## these values are written to a spreadsheet
## this script is adapted from the one on praatscriptingtutorial.com/filesExtendedExample 


clearinfo 

### set up variables--you may need to change the tier numbers based on the structure of your textgrid. 
askBeforeDelete = 1 
segTier = 2
wordTier = 4

wd$ = homeDirectory$ + "/Desktop/Enenlhet/"

## this will need to be changed along with the output file based on whether you're doing M or F speaker
inDir$ = wd$ + "input_5_5500/" 
inDirWavs$ = inDir$ + "*.wav"
outDir$ = wd$ + "output_formants/"	

#if not fileReadable: inDirWavs$
	#exitScript: "The input folder doesn't exist"
#endif

### output file 
outFile$ = outDir$ + "enenlhet_formants_5_5500.csv"

## create output folder if one doesn't already exist 
	createDirectory: outDir$

## ask if we want to overwrite the output file if one already exists 
	if askBeforeDelete and fileReadable: outFile$
	pauseScript: "The data spreadsheet already exists. Overwrite it?"
	endif 

##if we say yes, then overwrite the data file 
	deleteFile: outFile$ 

### default formant settings--I'm not really sure if this is necessary since I'm not using a settings file, but I'll make some default variables anyways 
timeStepDefault = 0.0
numFormantsDefault = 5.0
maxFormantDefault = 5500.0
windowLengthDefault = 0.025
preEmphasisDefault = 50.0

### write spreadsheet header to new file. Change the name of the spreadsheet if needed
sep$ = tab$

header$ = "fileName" + sep$
	...+ "intervalNumber" + sep$
	...+ "label" + sep$
	...+ "wordLabel" + sep$
	...+ "intervalStart" + sep$
	...+ "intervalEnd" + sep$
	...+ "midpoint" + sep$
	...+ "mid_F1" + sep$
	...+ "mid_F2" + sep$
	...+ "mid_F3" + sep$
	...+ "firstthird" + sep$
	...+ "first_F1" + sep$
	...+ "first_F2" + sep$
	...+ "first_F3" + sep$
	...+ "lastthird" + sep$
	...+ "last_F1" + sep$
	...+ "last_F2" + sep$
	...+ "last_F3" + sep$
	...+ "tenth_F1" + sep$
	...+ "tenth_F2" + sep$ 
	...+ "tenth_F3" + sep$ 
	...+ "HNR_Mid" + sep$ 
	...+ "HNR_Avg" + newline$

writeFile: outFile$, header$  

### get a list of wav files in the input directory 
wavList = Create Strings as file list: "wavList", inDirWavs$

selectObject: "Strings wavList"

##how many wav files are in the input directory? 

numFiles = Get number of strings
numFiles$ = string$: numFiles
appendInfoLine: "There are " + numFiles$ 
	... + " .wav files in this folder"


## for each file in the directory, list out the name and the path
for fileNum from 1 to numFiles 
	selectObject: wavList

	wavName$ = Get string: fileNum

	appendInfoLine: "The file is " + wavName$ 

	wavPath$ = inDir$ + wavName$ 
	appendInfoLine: "The file path is " + wavPath$


	### specify gender of speakers and set formant settings. 
	## This assumes as a default that the gender is f, but this can be changed in the form, it just needs something to start

	#form Enter speaker gender (m or f only)
		#sentence Gender f
	#endform 

	## for each wav file, open the corresponding text grid
	wav = Read from file: wavPath$ 

	## set up formant variables. 
	timeStep = timeStepDefault
	numFormants = numFormantsDefault
	maxFormant = maxFormantDefault 
	# this is the recommended max formant for men, and maxFormantDefault is the recommended one for women, at 5500 (set above) 
	# 4/4/23 changed this to max formant default and commented out the form that allows you to specify gender, because I am doing it individually for each speaker
	windowLength = windowLengthDefault
	preEmphasis = preEmphasisDefault

	### set up harmonicity variables: 
	timeStepH = 0.01
	minPitch = 75.0
	silenceThresh = 0.1
	periodsWindow = 1.0 

	## create formant object. We do this with an if statement so that we can change it based on gender
	selectObject: wav 

#	if gender$ = "f"
#	formantObj = To Formant (burg)... timeStep numFormants maxFormantDefault windowLength preEmphasis
#	else
	formantObj = To Formant (burg)... timeStep numFormants maxFormant windowLength preEmphasis
#	endif 

	selectObject: wav 

	harmonicityObj = To Harmonicity (cc)... timeStepH minPitch silenceThresh periodsWindow 
	## get the number of intervals --create the textgrid path and open it 

## the _zc bit is because this is how i named all my TextGrids with the zero crossings asjusted. Probably should change this but not today, Satan
	tgPath$ = inDir$ + wavName$ -".wav" + "_zc.TextGrid" 

	appendInfoLine: "The tgPath$ is " + tgPath$

		if fileReadable: tgPath$

		#### read the textgrid in 
		workingTextgrid = Read from file: tgPath$ 

		#### get the number of intervals
		numIntervals = Get number of intervals: segTier 

		##### for each interval....

			for intNum from 1 to numIntervals 

				##if not blank
				selectObject: "TextGrid " + wavName$ - ".wav" + "_zc"

				## get the label of the interval 
				label$ = Get label of interval: segTier, intNum 

				## if the label is aeo

					if index_regex: label$, "^[aeo]" 

					intStart = Get starting point: segTier, intNum 
					intEnd = Get end point: segTier, intNum 

					# find midpoint of interval 
					midpoint = intStart + ((intEnd - intStart) / 2)
					
					## find first third of interval
					## this is a third of the interval's total duration  
					onethird = (intEnd - intStart)/3 

					## this will put us at the midpoint of the first third
					firstthird = intStart + (onethird/2) 

					## find last third of interval 
					lastthird = intEnd-(onethird/2)

					tenth = intStart + (onethird/10)

					# this will get us the word label from the word tier 
			
					intWordNum = Get interval at time: wordTier, intStart
					intWord$ = Get label of interval: wordTier, intWordNum 

					# select formant object
					selectObject: formantObj

					# get F1 and F2 -- Get value at time: formant, time, units, interpolation method (the final 2 are praat default)

					mid_f1 = Get value at time: 1, midpoint, "Hertz", "Linear" 
					mid_f2 = Get value at time: 2, midpoint, "Hertz", "Linear" 
					mid_f3 = Get value at time: 3, midpoint, "Hertz", "Linear"
					first_f1 = Get value at time: 1, firstthird, "Hertz", "Linear"
					first_f2 = Get value at time: 2, firstthird, "Hertz", "Linear"
					first_f3 = Get value at time: 3, firstthird, "Hertz", "Linear"
					last_f1 = Get value at time: 1, lastthird, "Hertz", "Linear"
					last_f2 = Get value at time: 2, lastthird, "Hertz", "Linear"
					last_f3 = Get value at time: 3, lastthird, "Hertz", "Linear"
					tenth_f1 = Get value at time: 1, tenth, "Hertz", "Linear"
					tenth_f2 = Get value at time: 2, tenth, "Hertz", "Linear"
					tenth_f3 = Get value at time: 3, tenth, "Hertz", "Linear"

					# get Harmonics to Noise Ratio info 

					selectObject: harmonicityObj 

					hnrMid = Get value at time: midpoint, "cubic"
					hnrAvg = Get mean: intStart, intEnd

					# stringify all the variables 
					intStart$ = string$: intStart
					intEnd$ = string$: intEnd
					mid_f1$ = fixed$: mid_f1, 0
					mid_f2$ = fixed$: mid_f2, 0 
					mid_f3$ = fixed$: mid_f3, 0 
					midpoint$ = string$: midpoint
					intNum$ = string$: intNum
					firstthird$ = string$: firstthird
					lastthird$ = string$: lastthird
					first_f1$ = fixed$: first_f1, 0
					first_f2$ = fixed$: first_f2, 0
					first_f3$ = fixed$: first_f3, 0 
					last_f1$ = fixed$: last_f1, 0
					last_f2$ = fixed$: last_f2, 0 
					last_f3$ = fixed$: last_f3, 0
					tenth_f1$ = fixed$: tenth_f1, 0
					tenth_f2$ = fixed$: tenth_f2, 0
					tenth_f3$ = fixed$: tenth_f3, 0 
					hnrMid$ = fixed$: hnrMid, 0
					hnrAvg$ = fixed$: hnrAvg, 0  

					# create new data row
					dataRow$ = wavName$ + sep$
						...+ intNum$ + sep$ 
						...+ label$ + sep$
						...+ intWord$ + sep$
						...+ intStart$ + sep$
						...+ intEnd$ + sep$
						...+ midpoint$ + sep$
						...+ mid_f1$ + sep$ 
						...+ mid_f2$ + sep$
						...+ mid_f3$ + sep$
						...+ firstthird$ + sep$
						...+ first_f1$ + sep$
						...+ first_f2$ + sep$
						...+ first_f3$ + sep$
						...+ lastthird$ + sep$
						...+ last_f1$ + sep$
						...+ last_f2$ + sep$
						...+ last_f3$ + sep$ 
						...+ tenth_f1$ + sep$
						...+ tenth_f2$ + sep$
						...+ tenth_f3$ + sep$ 
						...+ hnrMid$ + sep$ 
						...+ hnrAvg$ + newline$

					# append to spreadsheet  

					appendFile: outFile$, dataRow$ 
					endif
			endfor
			###this just clears out the praat object window so it doesn't become overloaded 
			removeObject: wav
			removeObject: workingTextgrid
			removeObject: formantObj 
			removeObject: harmonicityObj
			removeObject: wavList
			
		endif 
endfor 

exitScript: "All done! Check the spreadsheet!"