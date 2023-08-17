#########################
# This is a script to get the values of 
# a number of different measures of voice quality 
# in each third of a vowel.
# You must have a folder with wav files and 
# corresponding textgrids of the same name.
# The script is written to reference and extract information
# from a number of different tiers (see below, remove if not needed).
# Results are written into a spreadsheet.
# Things that may need to change: 
# Working directory (where files are)
# Which tiers to get info from
# Assorted other settings

# This script was modified by Paige-Erin Wheeler from a model by Elizabeth Wood.
# Parts of this script were modified from a script by
# Chad Vicenik called praatvoicesauceimitator.praat
# taken from the UCLA phonetics lab website,
# which itself is based off of a similar script by Bert Remijsen.
# Other parts of this script were modified from 
# the formant script made by Daniel Riggs for his online
# Praat scripting tutorial.

clearinfo

# Set up the working directory
# for relative path names
wd$ = homeDirectory$ + "/Desktop/Enenlhet/"

inDir$ = wd$ + "input_all/"
inDirWavs$ = inDir$ + "*.wav"
outDir$ = wd$ + "output_voice/"	

# Set up variables to be used
sep$ = tab$
outFile$ = outDir$ + "voice_20230802.csv"
tierNum = 2


# Spectrogram settings
 windowLengthSpec = 0.005
 maxFreSpec = 5000
 timeStepSpec = 0.002
 freStepSpec = 20
 windowShapeSpec$ = "Gaussian"

# Pitch settings
timeStepPitch = 0 
# 0 means Praat will use 0.75/pitch floor
pitchFloor = 75.0 
maxCandidates = 15
accuracy$ = "no"
silenceThreshPitch = 0.03
voicingThreshPitch = 0.45
octaveCost = 0.01
octaveJumpCost = 0.5
# standard is 0.35
voicedUnvoicedCost = 0.14
pitchCeiling = 600 

# Harmonicity settings
 timeStepGlot = 0.01
 minPitch = 75
 silenceThresh = 0.01
 # standard is 0.1
 perPerWindow = 1.0

# Extract part settings
windowShapePart$ = "rectangular"
## whoever I stole this from used Hanning but rectangular is standard
relativeWidthPart = 1
preserveTimesPart$ = "no"

# Jitter settings
shortPerJitt = 0.0001
longPerJitt = 0.02
## script I copied used 0.05 but 0.02 is standard
maxPerFactJitt = 5
## script I copied used 5 but 1.3 is standard

# Shimmer settings
shortPerShim = 0.0001
longPerShim = 0.02
## script I copied used 0.05 but 0.02 is standard
maxPerFactShim = 1.3
## script I copied used 5 but 1.3 is standard
maxAmpFactShim = 5
## script I copied used 5 but 1.6 is standard

# CPPS settings 
pitchMinCPPS = 60.0
pitchMaxCPPS = 333.3
interpolationCPPS$ = "parabolic"
trendMinCPPS = 0.001
trendMaxCPPS = 0.05
trendTypeCPPS$ = "exponential decay"
fitMethodCPPS$ = "robust slow"

# Start the results table
createDirectory: outDir$

header$ = "fileName" + sep$
	...+ "intervalNumber" + sep$
	...+ "label" + sep$
	...+ "segDurationType" + sep$
	...+ "HNR_Mid1" + sep$ 
	...+ "HNR_Mid2" + sep$
	...+ "HNR_Mid3" + sep$
	...+ "HNR_Avg" + sep$
	...+ "HNR_Avg1" + sep$
	...+ "HNR_Avg2" + sep$
	...+ "HNR_Avg3" + sep$
	...+ "Intensity1" + sep$
	...+ "Intensity2" + sep$
	...+ "Intensity3" + sep$
	...+ "Jitter1" + sep$
	...+ "Jitter2" + sep$
	...+ "Jitter3" + sep$
	...+ "Shimmer1" + sep$ 
	...+ "Shimmer2" + sep$
	...+ "Shimmer3" + sep$
	...+ "H1-H2_1" + sep$
	...+ "H1-H2_2" + sep$
	...+ "H1-H2_3" + sep$
	...+ "Pitch1" + sep$
	...+ "Pitch2" + sep$
	...+ "Pitch3" + sep$
	...+ "CPPS1" + sep$
	...+ "CPPS2" + sep$
	...+ "CPPS3" + newline$
  

# Warning if a results file already exists
if fileReadable: outFile$
	pauseScript: "Data spreadsheet already exists, overwrite?"
endif	
deleteFile: outFile$

### write new spreadsheet with header row 

writeFile: outFile$, header$


# Create the string with all of the wav files

relFiles = Create Strings as file list: "relFiles", inDirWavs$

selectObject: "Strings relFiles"


# How many wav files are in the folder?

numFiles = Get number of strings
numFiles$ = string$: numFiles

appendInfoLine: "There are " + numFiles$ 
	... + " .wav files in this folder"

# Loop: this one is going through 
# each wav file in the folder 

for x from 1 to numFiles

	selectObject: relFiles

	# We want it to find the corresponding textgrid
	# The textgrid file must have the same name as the wav file
	# but will end in .TextGrid

	soundName$ = Get string: x
	appendInfoLine: "wav file " + soundName$
	textgridName$ = soundName$ - ".wav" + ".TextGrid"

	textgridxPath$ = inDir$ + textgridName$
	soundPath$ = inDir$ + soundName$

	if fileReadable: textgridxPath$
		textgridx = Read from file: textgridxPath$	

		# let's open the sound file and make the spectrogram object, the pitch object,
		# the intensity object and the harmonicity object

		soundx = Read from file: soundPath$

		selectObject: soundx
			spectrogramx = To Spectrogram: windowLengthSpec, maxFreSpec, timeStepSpec, freStepSpec, windowShapeSpec$

		selectObject: soundx
			pitchx = To Pitch (cc): timeStepPitch, pitchFloor, maxCandidates, accuracy$, silenceThreshPitch, 
			... voicingThreshPitch, octaveCost, octaveJumpCost, voicedUnvoicedCost, pitchCeiling
		pitchx_interpol= Interpolate
		Rename: soundName$ - ".wav" + "_interpolated"


		selectObject: soundx
			  harmonicityx = To Harmonicity (cc): timeStepGlot,
			  ... minPitch, silenceThresh, perPerWindow	

		selectObject: soundx
		intensityx = To Intensity: 100, 0, "no"

		selectObject: pitchx
		pointprocessx = To PointProcess


		# Now let's loop through each interval of the textgrid and get its label
		
		selectObject: textgridx
		numInt = Get number of intervals: tierNum
	
		numInt$= string$: numInt

		for i from 1 to numInt

			selectObject: textgridx
			intLabel$ = Get label of interval: tierNum, i

			# We will only perform the analysis for intervals beginning with /a e o/ 	

			if index_regex: intLabel$, "^[aeo]"
			  intStart = Get start time of interval: tierNum, i
			  intEnd = Get end time of interval: tierNum, i
			  intDur = intEnd - intStart
			  intMid = intStart + (intDur / 2)
			  intfirstthird = intStart + (intDur / 3)

		 		segDur = intDur / 3
		 		segDur$ = string$: segDur
				minSeg1Dur = 1 / pitchFloor
			 
				# In order to correctly make the measurements
				# Praat needs the window to be at least
				# 1/ pitch floor, so the size of the 
				# minimum segment for analysis will depend
				# on the pitch floor setting
				if segDur > minSeg1Dur

				  segEnd = intStart + segDur
				  middleStart = intStart + segDur
				  middleEnd = intStart + (2 * segDur)
				  secondSegStart = intStart + (2 * segDur)
				  segDurType$ = "seg1"
				  segActualDur = segDur 

				  else
				  		if intDur > minSeg1Dur

				  			segEnd = intStart + minSeg1Dur
				  			middleStart = intMid - (minSeg1Dur / 2)
				  			middleEnd = intMid + (minSeg1Dur / 2)
				  			secondSegStart = intEnd - minSeg1Dur
				  			segDurType$ = "min seg"
				  			segActualDur = minSeg1Dur
				  			
				 		else 
							  segEnd = intEnd
							  middleStart = intStart
							  middleEnd = intEnd
							  secondSegStart = intStart
							  segDurType$ = "whole interval"
							  segActualDur = intDur

				  		endif

			  	endif

			
			segmid1 = intStart + (segActualDur / 2)
			secondSegMid = secondSegStart + (segActualDur / 2)

			segActualDur$ = string$: segActualDur

			 intStart$ = string$: intStart
			 intDur$ = string$: intDur

			 i$ = string$: i

			# Now spectral measurements for the first segment

			selectObject: soundx
				
			soundx_1 = Extract part: intStart, segEnd, 
				... windowShapePart$, relativeWidthPart, preserveTimesPart$ 
			Rename: soundName$ - ".wav" + "_slice1"

				
			selectObject: soundx_1
			spectrumx_1 = To Spectrum: "yes" 
			ltasx_1 = To Ltas (1-to-1)
			
			selectObject: spectrumx_1
			cepstrumx_1 = To PowerCepstrum

			selectObject: pitchx_interpol
			segmid1f0 = Get value at time: segmid1, "hertz", "linear"
				
		
			if segmid1f0 <> undefined

				p10_segmid1f0 = segmid1f0 / 10
				selectObject: ltasx_1
				lowerbh1_seg1 = segmid1f0 - p10_segmid1f0
				upperbh1_seg1 = segmid1f0 + p10_segmid1f0
				lowerbh2_seg1 = (segmid1f0 * 2) - (p10_segmid1f0 * 2)
				upperbh2_seg1 = (segmid1f0 * 2) + (p10_segmid1f0 * 2)
				h1db_seg1 = Get maximum: lowerbh1_seg1, upperbh1_seg1, "none"
				h1hz_seg1 = Get frequency of maximum: lowerbh1_seg1, upperbh1_seg1, "none"
				h2db_seg1 = Get maximum: lowerbh2_seg1, upperbh2_seg1, "none"
				h2hz_seg1 = Get frequency of maximum: lowerbh2_seg1, upperbh2_seg1, "none"

				h1mnh2_seg1 = h1db_seg1 - h2db_seg1

				else
					h1mnh2_seg1 = 0
		
			endif 

			selectObject: cepstrumx_1
			cpps1 = Get peak prominence: pitchMinCPPS, pitchMaxCPPS, 
			... interpolationCPPS$, 
			... trendMinCPPS, trendMaxCPPS, 
			... trendTypeCPPS$, fitMethodCPPS$

			cpps1$ = string$: cpps1 

			h1mnh2_seg1$ = string$: h1mnh2_seg1

			# The same measurements for the middle segment
			selectObject: soundx
				
			soundx_2 = Extract part: middleStart, middleEnd, 
				... windowShapePart$, relativeWidthPart, preserveTimesPart$ 
			Rename: soundName$ - ".wav" + "_slice2"

				
			selectObject: soundx_2
			spectrumx_2 = To Spectrum: "yes" 
			ltasx_2 = To Ltas (1-to-1)
			
			selectObject: spectrumx_2
			cepstrumx_2 = To PowerCepstrum

			selectObject: pitchx_interpol
			segMiddlef0 = Get value at time: intMid, "hertz", "linear"
				
			if segMiddlef0 <> undefined

				p10_segMiddlef0 = segMiddlef0 / 10
				selectObject: ltasx_2 
				lowerbh1_middle = segMiddlef0 - p10_segMiddlef0
				upperbh1_middle = segMiddlef0 + p10_segMiddlef0
				lowerbh2_middle = (segMiddlef0 * 2) - (p10_segMiddlef0 * 2)
				upperbh2_middle = (segMiddlef0 * 2) + (p10_segMiddlef0 * 2)
				h1db_middle = Get maximum: lowerbh1_middle, upperbh1_middle, "none"
				h1hz_middle = Get frequency of maximum: lowerbh1_middle, upperbh1_middle, "none"
				h2db_middle = Get maximum: lowerbh2_middle, upperbh2_middle, "none"
				h2hz_middle = Get frequency of maximum: lowerbh2_middle, upperbh2_middle, "none"

				h1mnh2_middle = h1db_middle - h2db_middle
				

				else
					h1mnh2_middle = 0
					
			endif 

			selectObject: cepstrumx_2
			cpps2 = Get peak prominence: pitchMinCPPS, pitchMaxCPPS, 
			... interpolationCPPS$, 
			... trendMinCPPS, trendMaxCPPS, 
			... trendTypeCPPS$, fitMethodCPPS$

				cpps2$ = string$: cpps2 

				h1mnh2_middle$ = string$: h1mnh2_middle


			# And the same measurements for the third segment

			selectObject: soundx
			
			soundx_3 = Extract part: secondSegStart, intEnd, 
				... windowShapePart$, relativeWidthPart, preserveTimesPart$ 
			Rename: soundName$ - ".wav" + "_slice3"

				
			selectObject: soundx_3
			spectrumx_3 = To Spectrum: "yes" 
			ltasx_3 = To Ltas (1-to-1)
			
			selectObject: spectrumx_3
			cepstrumx_3 = To PowerCepstrum

			selectObject: pitchx_interpol
			secondSegf0 = Get value at time: secondSegMid, "hertz", "linear"

			if secondSegf0 <> undefined

				p10_SecondSegf0 = secondSegf0 / 10
				selectObject: ltasx_3
				lowerbh1_SecondSeg = secondSegf0 - p10_SecondSegf0
				upperbh1_SecondSeg = secondSegf0 + p10_SecondSegf0
				lowerbh2_SecondSeg = (secondSegf0 * 2) - (p10_SecondSegf0 * 2)
				upperbh2_SecondSeg = (secondSegf0 * 2) + (p10_SecondSegf0 * 2)
				h1db_SecondSeg = Get maximum: lowerbh1_SecondSeg, upperbh1_SecondSeg, "none"
				h1hz_SecondSeg = Get frequency of maximum: lowerbh1_SecondSeg, upperbh1_SecondSeg, "none"
				h2db_SecondSeg = Get maximum: lowerbh2_SecondSeg, upperbh2_SecondSeg, "none"
				h2hz_SecondSeg = Get frequency of maximum: lowerbh2_SecondSeg, upperbh2_SecondSeg, "none"

				h1mnh2_SecondSeg = h1db_SecondSeg - h2db_SecondSeg

				else
					h1mnh2_SecondSeg = 0
					
			endif 

			selectObject: cepstrumx_3
			cpps3 = Get peak prominence: pitchMinCPPS, pitchMaxCPPS, 
			... interpolationCPPS$, 
			... trendMinCPPS, trendMaxCPPS, 
			... trendTypeCPPS$, fitMethodCPPS$

				cpps3$ = string$: cpps3 

				h1mnh2_SecondSeg$ = string$: h1mnh2_SecondSeg
				

			# Intensity measurements (averaged over each third of the vowel)

			selectObject: intensityx
			
			intSeg1 = Get mean: intStart, segEnd, "energy"
			intSeg1$ = string$: intSeg1

			intMiddle = Get mean: middleStart, middleEnd, "energy"
			intMiddle$ = string$: intMiddle

			intSecondSeg = Get mean: secondSegStart, intEnd, "energy"
			intSecondSeg$ = string$: intSecondSeg


			# F0 measurements at midpoint of each third of the vowel 
			
			selectObject: pitchx
			pitchSeg1 = Get value at time: segmid1, "Hertz", "linear"
			pitchSeg1$ = string$: pitchSeg1

			pitchMiddle = Get value at time: intMid, "Hertz", "linear"
			pitchMiddle$ = string$: pitchMiddle
			
			pitchSecondSeg = Get value at time: secondSegMid, "Hertz", "linear"
			pitchSecondSeg$ = string$: pitchSecondSeg

			# HNR measurements at midpoint of each third and also the average over each third 

			selectObject: harmonicityx
			hnr_avg = Get mean: intStart, intEnd
			hnr_avg$ = string$: hnr_avg 

			hnr_mid1 = Get value at time: segmid1, "cubic"
			
			hnrmean1 = Get mean: intStart, segEnd
			hnrmean1$ = string$: hnrmean1
			hnr_mid1$ = string$: hnr_mid1

			hnr_mid2 = Get value at time: intMid, "cubic"

			hnrmean2 = Get mean: middleStart, middleEnd
			hnrmean2$ = string$: hnrmean2
			hnr_mid2$ = string$: hnr_mid2

			hnr_mid3 = Get value at time: secondSegMid, "cubic"

			hnrmean3 = Get mean: secondSegStart, intEnd
			hnrmean3$ = string$: hnrmean3
			hnr_mid3$ = string$: hnr_mid3 
			
			# Jitter measurements over each third 

			selectObject: pointprocessx
		
			jitterSeg1 = Get jitter (local): intStart, segEnd, shortPerJitt, longPerJitt, maxPerFactJitt
			jitterSeg1$ = string$: jitterSeg1

			jitterMiddle = Get jitter (local): middleStart, middleEnd, shortPerJitt, longPerJitt, maxPerFactJitt
			jitterMiddle$ = string$: jitterMiddle

			jitterSecondSeg = Get jitter (local): secondSegStart, intEnd, shortPerJitt, longPerJitt, maxPerFactJitt
			jitterSecondSeg$ = string$: jitterSecondSeg
			

			# Shimmer measurements over each third 

			selectObject: soundx
			plusObject: pointprocessx
			shimmerSeg1 = Get shimmer (local): intStart, segEnd, shortPerShim, longPerShim, maxPerFactShim, maxAmpFactShim
			shimmerSeg1$ = string$: shimmerSeg1

			shimmerMiddle = Get shimmer (local): middleStart, middleEnd, shortPerShim, longPerShim, maxPerFactShim, maxAmpFactShim
			shimmerMiddle$ = string$: shimmerMiddle

			shimmerSecondSeg = Get shimmer (local): secondSegStart, intEnd, shortPerShim, longPerShim, maxPerFactShim, maxAmpFactShim
			shimmerSecondSeg$ = string$: shimmerSecondSeg
			

		# Print out all of these measurements into the results table
		
	  		intInQuestRow$ = textgridName$ + sep$ 
	  			... + i$ + sep$ 
			  	... + intLabel$ + sep$ 
			  	... + segDurType$ + sep$
			  	... + hnr_avg$ + sep$ 
			  	... + hnr_mid1$ + sep$ 
			  	... + hnr_mid2$ + sep$ 
			  	... + hnr_mid3$ + sep$ 
			  	... + hnrmean1$ + sep$ 
			  	... + hnrmean2$ + sep$ 
			  	... + hnrmean3$ + sep$
			  	... + intSeg1$ + sep$
			  	... + intMiddle$ + sep$
			  	... + intSecondSeg$ + sep$ 
			  	... + jitterSeg1$ + sep$ 
			  	... + jitterMiddle$ + sep$ 
			  	... + jitterSecondSeg$ + sep$
			  	... + shimmerSeg1$ + sep$ 
			  	... + shimmerMiddle$ + sep$ 
			  	... + shimmerSecondSeg$ + sep$
			  	... + h1mnh2_seg1$ + sep$ 
			  	... + h1mnh2_middle$ + sep$ 
			  	... + h1mnh2_SecondSeg$ + sep$
			  	... + pitchSeg1$ + sep$ 
			  	... + pitchMiddle$ + sep$ 
			  	... + pitchSecondSeg$ + sep$  
			  	... + cpps1$ + sep$ 
			  	... + cpps2$ + sep$ 
			  	...+  cpps3$ + newline$

			  appendFile: outFile$, intInQuestRow$ 	

			  # Clean up the open files
				selectObject: soundx_1
				plusObject: spectrumx_1
				plusObject: ltasx_1
				plusObject: cepstrumx_1
				plusObject: soundx_2
				plusObject: spectrumx_2
				plusObject: ltasx_2
				plusObject: cepstrumx_2
				plusObject: soundx_3
				plusObject: spectrumx_3
				plusObject: ltasx_3
				plusObject: cepstrumx_3

				Remove

		## this is the "if it starts with aeo loop"	
		endif 

		selectObject: soundx
	plusObject: textgridx
	 plusObject: harmonicityx
	 plusObject: spectrogramx
	 plusObject: pitchx
	 plusObject: pitchx_interpol
	 plusObject: intensityx
	 plusObject: pointprocessx

	# ends the for each interval
	endfor 

# Clean up remaining open files


 	Remove
# if file readable (matching textgrid)
endif



 # ends the for each wav file
	endfor

selectObject: "Strings relFiles"
Remove

pauseScript: "All done!"