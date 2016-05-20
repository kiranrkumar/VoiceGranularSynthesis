README for VOGRE - VOice GRains with Emotion
Kiran Kumar
17 May, 2016

Demo available at https://www.youtube.com/watch?v=puXWMZ6bUCA

Introduction:
=================================

VOGRE is a granular synthesis engine that allows for the creation of two 
simultaneous layers of audio stream. The original source material is a 
collection of three (3) audio files:

- Hi_Happy.wav
- Hi_Neutral.wav
- Hi_Sad.wav

In this current package, six (6) additional audio files are also included:

- Hi_Happy_To_Neut.wav
- Hi_Happy_To_Sad.wav
- Hi_Neut_To_Happy.wav
- Hi_Neut_To_Sad.wav
- Hi_Sad_To_Happy.wav
- Hi_Sad_To_Neut.wav

These nine (9) audio files are included in the accompanying Audio_Sources
directory and are automatically referenced and used by the code.

In addition, you should have the following files, all in the main directory:

- detect_pitch_yin.m
- front_End.fig
- front_End.m
- granulate.m
- main.m
- makeGrain.m
- pitchShift.m
- preProcessing.m
- timeStretch.m
- transformPitch.m

You should also have an empty Audio_Output directory. Audio that you
generate and subsequent write to a file will be automatically saved in this
directory.

Installation:
=================================
No installation should be necessary. This code should run right out of the
box.

Running the Program:
=================================
Just run main.m from the central directory (where the code lives), and
you're good to go!

If you so choose, you can also execute the preProcessing.m script before
running main (or uncomment the appropriate lines in main.m to do it from 
there). The pre-processing runs the code that loads, pitch detects, and
transforms the audio sources into six more pitch-adjusted files. The
resulting six files are necessary for the program to work, but they are
already included in the appropriate directory for your convenience.