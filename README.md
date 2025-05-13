# Quick Introduction to PrEgg
## Introduction
This is a [Praat](https://www.fon.hum.uva.nl/praat/) script designed to extract F0, Contact Quotient (CQ), Skew Quotient (SQ), and Peak Increase in Contact (PIC) values from EGG signals.

## Installation
The Praat script was written in Praat version 6.1.53. Please install a version of Praat that is compatible.

1. Download PrEgg.Praat and save it to your computer
2. Open Praat by double clicking Praat.exe
3. Click `Praat > Open praat script...`
4. Locate and select PrEgg.Praat
5. From the Praat script window, click `Run > Run`

> [!WARNING]  
> I have yet to test the script on a Mac, so I am not sure whether that might cause errors. Presumably the main problem there would be the direction of slashes in the directory path - like any other Praat script.
> [!ANOTHER WARNING]  
> Some users have reached out with the problem of the script running for a long time with no output - in that case, I would recommend going back to the [first release](https://github.com/maypychan/praat-egg/releases/tag/v1.0) of the code (without SQ). I will fix this in the future, sorry!
  
## Details
The script reads all the files with a ".wav" extension in a given folder with only EGG files, and optionally also reads in corresponding ".TextGrid" files of the same name. The script generates three ".csv" files, one called "EGG.csv", one called "EGG_deriv.csv", the last called "EGG_sq.csv".

* "EGG.csv" includes CQ, OQ, F0, Energy at peak measurements.
* "EGG_deriv.csv" also includes PIC and PDC information.
* "EGG_sq.csv" includes SQ measurements.

The first part of the script includes a form where you may adjust your pitch settings, high-pass / low-pass filter settings, egg settings and indicate whether you have corresponding TextGrids. To begin with, please enter a folder path in the 'directory' part of the form.

> [!TIP]
> Personally I tend to put my Praat scripts in the same folder as my taget .wav files, in which case I can leave the directory as is without worrying about my path structure.

Pitch range settings are important for the detection of peaks in the signal, please enter a suitable pitch range and make any other adjustments for [advanced pitch settings](https://www.fon.hum.uva.nl/praat/manual/Sound__To_Pitch__ac____.html) for your all the .wav files in your folder. 

> [!NOTE]  
> Since the same settings will be applied to all the sound files in the folder, I recommend putting different speakers into their own folder and running the analysis folder by folder to make the necessary settings adjustments.

Please choose corresponding frequency ranges for high-pass and low-pass filtering the EGG signal. The high-pass filter is applied to the EGG signal prior to any analysis; the low-pass filter is used at the step of creating the [derivative](https://www.fon.hum.uva.nl/praat/manual/Electroglottogram__Derivative___.html) signal. Adjust other EGG settings as necessary for generating the [closed glottis intervals](https://www.fon.hum.uva.nl/praat/manual/Electroglottogram__To_TextGrid__closed_glottis____.html). 

> [!IMPORTANT]
> In running the script for my own purposes I have found that the script tended to crash when the 'peak threshold' setting is not well suited for a given .wav file. I have since then added a conditional in which if the chosen 'peak threshold' setting would have crashed the script, to try adding 0.01 to the peak threshold setting for that specific sound file until it finds a setting that does work. This has solved most of my crashes ever since. If the script continues to crash when searching for the closing threshold, I recommend checking the .wav file that crashed the script manually to search for any abnormalities.

If each sound file currently has an accompanying TextGrid, the script currently only reads information from one of the tiers in the TextGrid. Please enter the tier number that you wish to be included in the output csv. Alternatively, if there are no accompanying TextGrids, please enter 0 as the tier number. The output will still include timestamps in corresponding rows.

Lastly, the interpolation of [amplitude setting](https://www.fon.hum.uva.nl/praat/manual/Sound__Get_value_at_time___.html) may be adjusted, this is primarily for estimating the amplitude of the peaks, which is relevant for PIC measures. 

Please press `OK` for the script to begin running after you are satisfied with your setting choices. A pop up box saying "done!" will appear at the end if the script has successfully finished going through all the .wav files in the folder. 

> [!TIP]
> The current defaults in the script settings are already set to Praat's default for each corresponding function.

## Disclaimers and Other Notes
I began writing this script because of my own personal need. In starting to do articulatory experiments after COVID calmed down, I have learned that [EggWorks](http://phonetics.linguistics.ucla.edu/facilities/physiology/EGG.htm), developed by Dr. Henry Tehrani, was sadly no longer available for public use in 2022, and as such I have began to search for other alternatives. This included exploring [Praatdet](https://github.com/kirbyj/praatdet) by Dr. James Kirby, which greatly inspired my current script. In exploring these options, I have learned that the latest versions of Praat included new functions for working with EGG signals, which is why I have decided to explore implementing these new functions into my own script. As such I wish to clarify that these are my own implementations and interpretations and I cannot guarantee identical results from other methods of analyzing EGG signals.

> [!CAUTION]
> In testing the validity of the script I have compared results with the CQ and CQ_PM measures from EGG data on Yi provided in the [“Production and Perception of Linguistic Voice Quality”](https://phonetics.ucla.edu/voiceproject/voice.html) project at UCLA. While overall results and trends are comparable, I would take note that most deviations occur near the edges of the vowels. Therefore I would recommend focusing on results from more steady-state portions of vowels when using PrEgg. I have also yet to test the performance of the script on fully creaky voice data.

## Citations and Acknowledgements
* Henrich N., d'Alessandro C., Castellengo M. and Doval B.. (2004). "On the use of the derivative of electroglottographic signals for characterization of nonpathological voice phonation", J. Acous. Soc. Am. 115(3), 1321-1332.
* Kirby, J. 2020. Praatdet: Praat-based tools for EGG analysis (v0.3). from https://github.com/kirbyj/praatdet.
* Kuang, J. (2011). Production and perception of the phonation contrast in Yi. UCLA
* Kuang, J. (2013). Phonation in tonal contrasts. UCLA.
* Rothenberg, M., & Mahshie, J. J. (1988). Monitoring vocal fold abduction through vocal fold contact area. Journal of Speech, Language, and Hearing Research, 31(3), 338-351.
* Tehrani., H. EggWorks. from http://phonetics.linguistics.ucla.edu/facilities/physiology/EGG.htm.

## Citing PrEgg
Chan, May Pik Yu & Jianjing Kuang 2024. PrEgg:A free and open source Praat script for electroglottography measurements (v0.1). Retrieved on (date) from https://github.com/maypychan/praat-egg.
