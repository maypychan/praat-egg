#########################
#### May Pik Yu Chan ####
## pikyu@sas.upenn.edu ##
# last edited: 05/13/24 #
#########################

form Directory:
	comment Please enter your directory
	sentence directory .\

  	comment Set pitch range:
 	natural Pitch_min 75
	natural Pitch_max 500

	comment Adjust advanced pitch settings if necessary:
  	positive Silence_threshold 0.03
  	positive Voicing_threshold 0.45
  	positive Octave_cost 0.01
  	positive Octave_jump_cost 0.35
  	positive Voiced_cost 0.14

	comment filter range:
	natural low_pass 5000
	natural high_pass 40

	comment egg settings:
	natural	smoothing 100
	positive closing_threshold 0.30
	positive peak_threshold 0.05
	positive sq_threshold 0.10

	comment which tier? (0 if none):
	real tier 1

	comment interpolation of amplitude:
	optionmenu interpolation 4
          option nearest
          option linear
          option cubic
	  option sinc70
	  option sinc700

endform

#####
filestrings = Create Strings as file list: "list", directory$ + "/*.wav"
number_files = Get number of strings

output_file$ = "EGG.csv"
writeFile: output_file$
appendFile: output_file$, "Filename", ",", "TgInterval", ",", "TgIntvlLabel", ",", "GlotInterval", ",", "GlotNextInterval", ",", "c_starttime", ",", "c_endtime", ",", "o_endtime", ",", "c_dur", ",", "o_dur", ",", "cq", ",", "oq", ",", "closing/opening", ",", "p_pascal", ",", "f0_midpoint", newline$

output_file_deriv$ = "EGG_deriv.csv"
writeFile: output_file_deriv$
appendFile: output_file_deriv$, "Filename", ",", "TgInterval", ",", "TgIntvlLabel", ",", "GlotInterval", ",", "GlotNextInterval", ",", "c_starttime", ",", "c_endtime", ",", "o_endtime", ",", "c_dur", ",", "o_dur", ",", "cq", ",", "oq", ",", "closing/opening", ",", "p_pascal", ",", "pic", ",", "pdc", ",", "f0_midpoint", newline$

output_file_sq$ = "EGG_sq.csv"
writeFile: output_file_sq$
appendFile: output_file_sq$, "Filename", ",", "TgInterval", ",", "TgIntvlLabel", ",", "OpeningInterval", ",", "ClosingInterval", ",", "c_starttime", ",", "c_endtime", ",", "o_starttime", ",", "o_endtime", ",", "c_dur", ",", "o_dur", ",", "sq", newline$

for j from 1 to number_files

	# Query the file-list to get the first filename from it, then read that file in:
	select filestrings
	current_token$ = Get string... 'j'
	wavfile_raw = Read from file: directory$ + "/" + current_token$
	filename$ = selected$ ("Sound") - ".wav"

	#pitch object
	selectObject: wavfile_raw
	pitch = To Pitch (ac): 0, pitch_min, 15, "no", silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_cost, pitch_max

	# If textgrid exists, open it
	if tier > 0
		textgrid_raw = Read from file: directory$ + "/" + filename$ + ".TextGrid"
	endif

	selectObject: wavfile_raw
	egg = Extract Electroglottogram: 1, "no"
	eggfilter = High-pass filter: high_pass, smoothing

	#Derivative Signal
	deriv = Derivative: low_pass, smoothing, 0
	#Save as WAV file: directory$ + "/" + filename$ + "_Deriv.wav"

	#Get closed glottis intervals
	selectObject: eggfilter
	closedIs = nocheck Get closed glottis intervals: pitch_min, pitch_max, closing_threshold, peak_threshold

	objName$ = selected$()
	p = 0.01
	x = startsWith(objName$, "Electroglottogram")

	while x == 1
		closedIs = nocheck Get closed glottis intervals: pitch_min, pitch_max, closing_threshold, peak_threshold + p
		#nocheck tg_CI = Into TextGrid
		p = p + 0.01
		#tg_CI$ = selected$(TextGrid)
		x = startsWith(objName$, "Electroglottogram")
	endwhile
	#tg_CI = Into TextGrid
	Save as text file: directory$ + "/" + filename$ + "_CGintervals.TextGrid"
	#removeObject: closedIs

############# SQ ##############

	#Get closed glottis intervals for SQ - bottom threshold
	selectObject: eggfilter
	closedIs_sq = nocheck Get closed glottis intervals: pitch_min, pitch_max, sq_threshold, peak_threshold

	objName$ = selected$()
	p_sq = 0.01
	x_sq = startsWith(objName$, "Electroglottogram")

	while x_sq == 1
		closedIs_sq = nocheck Get closed glottis intervals: pitch_min, pitch_max, sq_threshold, peak_threshold + p
		#nocheck tg_CI_sq = Into TextGrid
		p_sq = p + 0.01
		#tg_CI_sq$ = selected$(TextGrid)
		x_sq = startsWith(objName$, "Electroglottogram")
	endwhile
	#tg_CI_sq = Into TextGrid
	Save as text file: directory$ + "/" + filename$ + "_SQ_Low_intervals.TextGrid"
	#removeObject: closedIs_sq

	#Get closed glottis intervals for SQ - top threshold
	selectObject: eggfilter
	closedIs_sqt = nocheck Get closed glottis intervals: pitch_min, pitch_max, 1-sq_threshold, peak_threshold

	objName$ = selected$()
	p_sqt = 0.01
	x_sqt = startsWith(objName$, "Electroglottogram")

	while x_sqt == 1
		closedIs_sqt = nocheck Get closed glottis intervals: pitch_min, pitch_max, 1-sq_threshold, peak_threshold + p
		#nocheck tg_CI_sqt = Into TextGrid
		p_sqt = p + 0.01
		#tg_CI_sqt$ = selected$(TextGrid)
		x_sqt = startsWith(objName$, "Electroglottogram")
	endwhile
	#tg_CI_sqt = Into TextGrid
	Save as text file: directory$ + "/" + filename$ + "_SQ_Top_intervals.TextGrid"
	#removeObject: closedIs_sqt

	### Merge two tiers

	selectObject: closedIs_sq
	plusObject: closedIs_sqt
	tg_CI_SQ = Merge

	removeObject: closedIs_sq
	removeObject: closedIs_sqt

	selectObject: tg_CI_SQ
	Duplicate tier: 1, 3, "Merged"

	nInt_sq = do ("Get number of intervals...", 2)

	for s from 1 to nInt_sq-1

		endtime_CI = Get end time of interval: 2, s
		Insert boundary: 3, endtime_CI

	endfor

	#set interval text
	nInt_t3 = do ("Get number of intervals...", 3)
	for t from 1 to nInt_t3

		starttime_t3 = Get start time of interval: 3, t
		endtime_t3 = Get end time of interval: 3, t
		midpoint = starttime_t3 + (endtime_t3 - starttime_t3)/2

		top_int = Get interval at time: 1, midpoint
		bottom_int = Get interval at time: 2, midpoint

		top_lab$ = Get label of interval: 1, top_int
		bottom_lab$ = Get label of interval: 2, bottom_int

		starttime_t1 = Get start time of interval: 1, top_int
		endtime_t1 = Get end time of interval: 1, top_int
		midpoint_t1 = starttime_t1 + (endtime_t1 - starttime_t1)/2

		#labels
		if top_lab$ == "c" & bottom_lab$ == "" & midpoint < midpoint_t1
			Set interval text: 3, t, "c"
		elif top_lab$ == "c" & bottom_lab$ == "" & midpoint > midpoint_t1
			Set interval text: 3, t, "o"
		elif top_lab$ == "c" & bottom_lab$ == "c"
			Set interval text: 3, t, "NA"
		else
			Set interval text: 3, t, ""
		endif

	endfor

	#For checking purposes
	Insert point tier: 4, "check"

	#measurements
	for t from 3 to nInt_t3

		selectObject: tg_CI_SQ
		current_lab$ = Get label of interval: 3, t
		prev_lab$ = Get label of interval: 3, t-1
		prevprev_lab$ = Get label of interval: 3, t-2

		if current_lab$ == "o" & prev_lab$ == "NA" & prevprev_lab$ == "c"

			c_starttime = Get start time of interval: 3, t-2
			c_endtime = Get end time of interval: 3, t-2
			c_dur = c_endtime - c_starttime

			o_starttime = Get start time of interval: 3, t
			o_endtime = Get end time of interval: 3, t
			o_dur = o_endtime - o_starttime

			sq = c_dur / o_dur

			#For checking purposes, a point on tier four refers to where the SQ was taken
			Insert point: 4, o_endtime, fixed$(sq,3)

			if tier > 0
				selectObject: textgrid_raw
				current_interval = Get interval at time: tier, o_starttime
				if current_interval > 0
					intvl_label$ = Get label of interval: 1, current_interval
				else
					intvl_label$ = "NA"
				endif
			else
				current_interval = 0
				intvl_label$ = "NA"

			endif

			appendFile: output_file_sq$, filename$, ",", current_interval, ",", intvl_label$, ",", t, ",", t-2, ",", c_starttime, ",", c_endtime, ",", o_starttime, ",", o_endtime, ",", c_dur, ",", o_dur, ",", sq, newline$

		endif




	endfor


###############################

	# Use filtered egg signal for upcoming analysis
	# do wavfile = wavfile_raw if we want to use the unfiltered signal
	selectObject: eggfilter
	wavfile = To Sound

	# Use (periodic, peaks), instead of pitch, to point process because (ac) gets 0 pts, (cc) gets neg peak
	selectObject: wavfile
	pulses = To PointProcess (periodic, peaks): pitch_min, pitch_max, "yes", "no"
	texttier = Up to TextTier: "p"
	tg_Peak = Into TextGrid

	# Merge TextGrids
	selectObject: closedIs
	plusObject: tg_Peak
	tg_CIp = Merge
	Insert point tier: 3, "ClsIntvlTimes"

	# Intermediate cleaning
	removeObject: egg
	removeObject: eggfilter
	removeObject: tg_Peak
	removeObject: closedIs
	removeObject: pulses
	removeObject: texttier

	### Taking numbers from the TextGrid
	selectObject: tg_CIp
	nInt = do ("Get number of intervals...", 1)

	for i from 2 to nInt

		time_CI = Get start time of interval: 1, i
		endtime_CI = Get end time of interval: 1, i

		# Checking whether the wave is going up or down

		# Using 0.1% of the udration of the cycle to as following / prev check points
		# if the following interval is too far away, it takes the dur as 0.01 (change this as necessary)
		dur = (endtime_CI - time_CI)
		if dur < 0.01
			dur = dur
		else
			dur = 0.01
		endif

		fol_10perc = time_CI + dur*0.1
		prev_10perc = time_CI - dur*0.1

		selectObject: wavfile
		point_y = Get value at time: 0, time_CI, "sinc70"
		fol_y = Get value at time: 0, fol_10perc, "sinc70"
		prev_y = Get value at time: 0, prev_10perc, "sinc70"

		selectObject: tg_CIp
		if fol_y > point_y
			Insert point: 3, time_CI, "t1"
		elif prev_y > point_y
			Insert point: 3, time_CI, "t2"
		else
			Insert point: 3, time_CI, "error"
		endif

	endfor

	# Renaming and checking tier 1
	selectObject: tg_CIp
	Set tier name: 2, "Peak"
	Set tier name: 1, "ClosedInterval"
	Replace interval texts: 1, 1, 0, "c", "", "literals"

	# Label closing intervals and opening intervals
	for i from 2 to nInt
		starttime = Get start time of interval: 1, i
		endtime = Get end time of interval: 1, i

		ptlabel_start$ = Get label of point: 3, i-1

		if i != nInt
			ptlabel_end$ = Get label of point: 3, i
		endif

		#check if there's a peak in between
		#this chunk of code finds the index of the point closest to the midpoint
		#of the interval, then grabs the time of the peak

		midpoint = (endtime - starttime)/2 + starttime
		peak_index = Get nearest index from time: 2, midpoint
		peak_time = Get time of point: 2, peak_index

		#if the time of the peak is between t1 and t2,
		# and the peak closesest to the midpoint of the interval is within the interval, then it's a closed interval
		if ptlabel_start$ == "t1" and ptlabel_end$ == "t2" and peak_time > starttime and peak_time < endtime
			Set interval text: 1, i, "c"

		#if we find a peak in an open interval, we probably want to skip it
		#since it's probably a long region of no voicing
		#or some part of the signal got a little messy
		elif ptlabel_start$ == "t2" and ptlabel_end$ == "t1" and peak_time > starttime and peak_time < endtime
			Set interval text: 1, i, "skip"

		#if the start of the interval corresponds to a t2 label, and the end of the interval has a t1 label,
		#it's probably an open interval
		elif ptlabel_start$ == "t2" and ptlabel_end$ == "t1"
			Set interval text: 1, i, "o"
		endif

	endfor

	## Derivative signal
	# Getting deriv_closing
	selectObject: deriv
	pulse_pic = To PointProcess (periodic, peaks): pitch_min, pitch_max, "yes", "no"
	texttier_pic = Up to TextTier: "d1"
	tg_pic = Into TextGrid
	removeObject: pulse_pic
	removeObject: texttier_pic

	# Getting deriv_opening
	selectObject: deriv
	pulse_pdc = To PointProcess (periodic, peaks): pitch_min, pitch_max, "no", "yes"
	texttier_pdc = Up to TextTier: "d2"
	tg_pdc = Into TextGrid
	removeObject: pulse_pdc
	removeObject: texttier_pdc

	# Merge TextGrids
	selectObject: tg_CIp
	plusObject: tg_pic
	plusObject: tg_pdc
	tg_CIDeriv = Merge
	removeObject: tg_pic
	removeObject: tg_pdc
	removeObject: tg_CIp
	selectObject: tg_CIDeriv

	Insert interval tier: 6, "Deriv"
	d1_npts = Get number of points: 4
	Set tier name: 4, "Intervals_Deriv"
	for i to d1_npts
		d1_time = Get time of point: 4, i
		selectObject: tg_CIDeriv
		Insert boundary: 6, d1_time
	endfor

	d2_npts = Get number of points: 5
	for i to d2_npts
		d2_time = Get time of point: 5, i
		selectObject: tg_CIDeriv
		Insert boundary: 6, d2_time
		Insert point: 4, d2_time, "d2"
	endfor

	# Label closing intervals and opening intervals for deriv
	## NOTE: This is more problematic than the threshold version, so I have an extra (somewhat arbitrary) criterion - see comments below
	nInt_d = do ("Get number of intervals...", 6)

	for i from 2 to nInt_d
		starttime = Get start time of interval: 6, i
		endtime = Get end time of interval: 6, i

		ptlabel_start$ = Get label of point: 4, i-1

		if i != nInt_d
			ptlabel_end$ = Get label of point: 4, i
		endif

		midpoint = (endtime - starttime)/2 + starttime
		peak_index = Get nearest index from time: 2, midpoint
		peak_time = Get time of point: 2, peak_index

		#NOTE: Adding duration of the interval into consideration
		intvldur = endtime - starttime
		totaldur = Get total duration of intervals where: 6, "is equal to", ""
		avgdur = totaldur/nInt_d
		#Adding the condition that the closing and opening intervals cannot be longer than the avgerage duration intervals


		#if the time of the peak is between d1 and d2,
		# and the peak closesest to the midpoint of the interval is within the interval, then it's a closed interval
		if ptlabel_start$ == "d1" and ptlabel_end$ == "d2" and peak_time > starttime and peak_time < endtime and intvldur < avgdur
			Set interval text: 6, i, "c"

		#if we find a peak in an open interval, we probably want to skip it
		#since it's probably a long region of no voicing
		#or some part of the signal got a little messy
		elif ptlabel_start$ == "d2" and ptlabel_end$ == "d1" and peak_time > starttime and peak_time < endtime
			Set interval text: 6, i, "skip"

		#if the start of the interval corresponds to a d2 label, and the end of the interval has a d1 label,
		#it's probably an open interval
		elif ptlabel_start$ == "d2" and ptlabel_end$ == "d1" and intvldur < avgdur
			Set interval text: 6, i, "o"
		endif

	endfor
	Remove tier: 5


	# Calculating Closed / Closed + Open and Closed / Open
	for i from 1 to nInt-1
		selectObject: tg_CIDeriv
		intval$ = Get label of interval: 1, i
		nextval$ = Get label of interval: 1, i+1

		if intval$ == "c" and nextval$ == "o"
			c_starttime = Get start time of interval: 1, i
			c_endtime = Get end time of interval: 1, i
			o_endtime = Get end time of interval: 1, i+1
			c_dur = c_endtime - c_starttime
			o_dur = o_endtime - c_endtime

			cq = c_dur / (c_dur + o_dur)
			oq = o_dur / (o_dur + c_dur)
			c_o_ratio = c_dur / o_dur

			#amplitude of peak
			midpoint = c_dur/2 + c_starttime
			peak_index = Get nearest index from time: 2, midpoint
			peak_time = Get time of point: 2, peak_index

			#pitch
			selectObject: pitch
			f0_midpoint = Get value at time: midpoint, "Hertz", "linear"

			selectObject: wavfile
			p_pascal = Get value at time: 0, peak_time, interpolation$

			if tier > 0
				selectObject: textgrid_raw
				current_interval = Get interval at time: tier, peak_time
				if current_interval > 0
					intvl_label$ = Get label of interval: 1, current_interval
				else
					intvl_label$ = "NA"
				endif
			else
				current_interval = 0
				intvl_label$ = "NA"

			endif

			appendFile: output_file$, filename$, ",", current_interval, ",", intvl_label$, ",", i, ",", i+1, ",", c_starttime, ",", c_endtime, ",", o_endtime, ",", c_dur, ",", o_dur, ",", cq, ",", oq, ",", c_o_ratio, ",", p_pascal, ",", f0_midpoint, newline$

		endif

	endfor

	# Calculating Closed / Closed + Open and Closed / Open with Deriv
	for i from 1 to nInt_d-1
		selectObject: tg_CIDeriv
		intval$ = Get label of interval: 5, i
		nextval$ = Get label of interval: 5, i+1

		if intval$ == "c" and nextval$ == "o"
			c_starttime = Get start time of interval: 5, i
			c_endtime = Get end time of interval: 5, i
			o_endtime = Get end time of interval: 5, i+1
			c_dur = c_endtime - c_starttime
			o_dur = o_endtime - c_endtime

			cq = c_dur / (c_dur + o_dur)
			oq = o_dur / (o_dur + c_dur)
			c_o_ratio = c_dur / o_dur

			#amplitude of peak
			midpoint = c_dur/2 + c_starttime
			peak_index = Get nearest index from time: 2, midpoint
			peak_time = Get time of point: 2, peak_index

			#pitch
			selectObject: pitch
			f0_midpoint = Get value at time: midpoint, "Hertz", "linear"

			selectObject: wavfile
			p_pascal = Get value at time: 0, peak_time, interpolation$

			selectObject: deriv
			pic = Get value at time: 0, c_starttime, interpolation$
			pdc = Get value at time: 0, c_endtime, interpolation$

			if tier > 0
				selectObject: textgrid_raw
				current_interval = Get interval at time: tier, peak_time
				if current_interval > 0
					intvl_label$ = Get label of interval: 1, current_interval
				else
					intvl_label$ = "NA"
				endif
			else
				current_interval = 0
				intvl_label$ = "NA"
			endif

			appendFile: output_file_deriv$, filename$, ",", current_interval, ",", intvl_label$, ",", i, ",", i+1, ",", c_starttime, ",", c_endtime, ",", o_endtime, ",", c_dur, ",", o_dur, ",", cq, ",", oq, ",", c_o_ratio, ",", p_pascal, ",", pic, ",", pdc, ",", f0_midpoint, newline$
		endif

	endfor

	removeObject: wavfile_raw
	removeObject: wavfile
	removeObject: deriv
	removeObject: tg_CIDeriv
	removeObject: pitch

	if tier > 0
		removeObject: textgrid_raw
	endif
endfor


appendInfoLine: "done!"
