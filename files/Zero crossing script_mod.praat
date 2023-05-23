# This script creates a new tier in a textgrid
# that copies interval boundaries from another tier
# but shifts them to the nearest zero crossing.
# If non-empty, it copies the label of the interval as well.
# It also creates a second new tier 
# with the same boundaries but no interval labels.
# This tier is named "Notes".
# Then it deletes the original tier (to disable, comment out command
# " Remove tier: tierNum")
# and saves the textgrid with the same name + _zc.
# This script was made by Elizabeth Wood by
# modifying a similar script made
# by Dan Brenner, dbrenner@email.arizona.edu

##script modified by Paige-Erin Wheeler, 23 August 2023

clearinfo

# Set up the working directory
# for relative path names

wd$ = homeDirectory$ + "/Desktop/Enenlhet/"

inDir$ = wd$ + "new_input/"
inDirWavs$ = inDir$ + "*.wav"
outDir$ = wd$ + "output_LF/"	


## create the output folder
createDirectory: outDir$

# choose which tier to copy
tierNum = 1

# Create the string with all of the wav files
relFiles = Create Strings as file list: "relFiles", inDirWavs$
selectObject: "Strings relFiles"

# How many wav files?
numFiles = Get number of strings
numFiles$ = string$: numFiles
appendInfoLine: "There are " + numFiles$ 
	... + " .wav files in this folder"

# Loop through each wav file
for x from 1 to numFiles
	selectObject: relFiles

# We want it to find the corresponding textgrid
# The textgrid file will be named like the wav
	textgridName$ = Get string: x
	appendInfoLine: "wav file " + textgridName$

# Its path will end in .TextGrid though
	textgridxPath$ = inDir$ + textgridName$ - ".wav" + ".TextGrid"
	soundPath$ = inDir$ + textgridName$

# Open the matching textgrid and wav
if fileReadable: textgridxPath$
	textgridx = Read from file: textgridxPath$	
	soundx = Read from file: soundPath$

# Select the textgrid to get the relevant info 
	selectObject: "TextGrid " + textgridName$ - ".wav"	
	tierLab$ = Get tier name: tierNum 
	
# Make the new tier	
	newTierLab$ = tierLab$ + "ZC"
	newTierNum = tierNum + 1
	Insert interval tier: newTierNum, newTierLab$

# Find out how many intervals in the tier
	numInt = Get number of intervals: tierNum
	numIntPen = numInt - 1

# Loop through every interval except the last one
# (which doesn't have an end boundary to place)
# For each, get the end boundary location,
# get the nearest zero crossing to that point,
# and then draw a boundary on the new tier
		for y from 1 to numIntPen
			intEnd = Get end time of interval: tierNum, y 
			selectObject: "Sound " + textgridName$ - ".wav"
			zercrosEnd = Get nearest zero crossing: 1, intEnd

			selectObject: "TextGrid " + textgridName$ - ".wav"
			Insert boundary: newTierNum, zercrosEnd

# Copy over the interval label if not empty

			intLabel$ = Get label of interval: tierNum, y

			##this regex only copies over the intervals labeled with vowel information because that is all I need 
				if index_regex: intLabel$, "^[aeo]" 
					Set interval text: newTierNum, y, intLabel$
				endif 

# for each interval
		endfor 





# This part here also adds another tier 
# with the same boundaries but empty 
# that is called "Notes"
	#selectObject: "TextGrid " + textgridName$ - ".wav"	
	#tierLab$ = Get tier name: tierNum 

# Make the new tier	
	#newTier2Lab$ = "Notes"
	#newTier2Num = tierNum + 2
	#Insert interval tier: newTier2Num, newTier2Lab$

# Find out how many intervals in the tier
	#numInt = Get number of intervals: tierNum
	#numIntPen = numInt - 1

# Loop through every interval except the last one
# (which doesn't have an end boundary to place)
# For each, get the end boundary location,
# get the nearest zero crossing to that point,
# and then draw a boundary on the new tier
		#for y from 1 to numIntPen
		#	intEnd = Get end time of interval: tierNum, y 
		#	selectObject: "Sound " + textgridName$ - ".wav"
		#	zercrosEnd = Get nearest zero crossing: 1, intEnd

			#selectObject: "TextGrid " + textgridName$ - ".wav"
		#	Insert boundary: newTier2Num, zercrosEnd

# for each interval
		#endfor 


# This ends the part inserting the second notes tier




# Delete the original tier
#	Remove tier: tierNum

# Save the new textgrid with a new name
Save as text file: inDir$ + textgridName$ - ".wav" + "_zc.TextGrid"

# Remove the textgrid and wav file
selectObject: "TextGrid " + textgridName$ - ".wav"
plusObject: "Sound " + textgridName$ - ".wav"
Remove


# if there is a matching textgrid
		endif 


# for each wav file
	endfor 
	
# Remove the strings object
selectObject: "Strings relFiles"
Remove

pauseScript: "All done!"