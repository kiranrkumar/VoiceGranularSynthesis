%% Create audio files and variables are are necessary for the frontEnd.m 
%   GUI to run.
%   CAUTION: may take a while!
%
%   Kiran Kumar | 17 May, 2016
%
%% WARNING! Closes and clears all data!
close; clear;

%% Initialization

%Read in the audio files - assume they all have the same sampling rate
%(because they do)

sourceDir = 'Audio_Sources';
[hiHappy, fs] = audioread(fullfile(pwd, sourceDir, 'Hi_Happy.wav'));
hiNeut = audioread(fullfile(pwd, sourceDir, 'Hi_Neutral.wav'));
hiSad = audioread(fullfile(pwd, sourceDir, 'Hi_Sad.wav'));

%Normalize all three
hiHappy = hiHappy / max(abs(hiHappy));
hiNeut = hiNeut / max(abs(hiNeut));
hiSad = hiSad / max(abs(hiSad));

%turn off warnings so that the granulate and makeGrain functions don't spit
%   out a bunch of stuff
warning('off', 'all');

%% Get the pitch contour of each audio sample
    
%yin parameters
minFreq = 60;
maxFreq = 350; %my spoken voice won't go higher than this
max_lag = round(fs / minFreq); %sample delay for min frequency
min_lag = round(fs / maxFreq); %sample delay for max frequency
win_size = 2048;
hop_size = 64;

%Use Yin to get pitch over time for each recording
disp('Calculating pitch contours....0/3');
[pitchHappy, tPitchHappy, yinValsHappy] = detect_pitch_yin(hiHappy, fs, ...
    win_size, hop_size, min_lag, max_lag);
disp('1/3');
[pitchNeut, tPitchNeut, yinValsNeut] = detect_pitch_yin(hiNeut, fs, ...
    win_size, hop_size, min_lag, max_lag);
disp('2/3');
[pitchSad, tPitchSad, yinValsSad] = detect_pitch_yin(hiSad, fs, ...
    win_size, hop_size, min_lag, max_lag);
disp('3/3...Done!');

%these pitch windows are spastic. Smooth them out with a lowpass filter
[b,a] = butter(1, 1000 / (fs/2), 'low'); %1st order butterworth lowpass @ 1000 Hz

disp('Low-pass filtering pitch windows....0/3');
pitchHappy = filter(b, a, pitchHappy);
disp('1/3');
pitchNeut = filter(b, a, pitchNeut);
disp('2/3');
pitchSad = filter(b, a, pitchSad);
disp('3/3....Done!');

%find max pitch in all windows and divide all windows by that to normalize
maxPitch = max([pitchHappy, pitchNeut, pitchSad]);
pitchHappy = pitchHappy / maxPitch;
pitchNeut = pitchNeut / maxPitch;
pitchSad = pitchSad / maxPitch;

%get rid of beginning and trailing zeros

%make all of the pitch windows the same length for easy transformation
%   later
minWinSize = min( [length(pitchHappy), length(pitchNeut), length(pitchSad) ] );
pitchHappy = resample(pitchHappy, minWinSize, length(pitchHappy));
pitchNeut = resample(pitchNeut, minWinSize, length(pitchNeut));
pitchSad = resample(pitchSad, minWinSize, length(pitchSad));

%add a little to the min (since resample() in pitchShift can't work with a 
%   0 value) and rescale to [-1, 1]
pitchHappy = pitchHappy * 0.9 + 0.1;
pitchNeut = pitchNeut * 0.9 + 0.1;
pitchSad = pitchSad * 0.9 + 0.1;

%precalculate "emotional transform" signals, i.e. transforming a happy
%   sound into a sad sound, a neutral sound into a happy sound, etc....

    %transform pitch windows
    happyToSad = pitchSad ./ pitchHappy;
    happyToNeut = pitchNeut ./ pitchHappy;
    sadToHappy = pitchHappy ./ pitchSad;
    sadToNeut = pitchNeut ./ pitchSad;
    neutToHappy = pitchHappy ./ pitchNeut;
    neutToSad = pitchSad ./ pitchNeut;
 
    %downsample these windows so that pitch transformations don't take
    %   freaking forever
    newlen = 20; %sample
    happyToSad = resample(happyToSad, newlen, length(happyToSad));
    happyToNeut = resample(happyToNeut, newlen, length(happyToNeut));
    sadToHappy = resample(sadToHappy, newlen, length(sadToHappy));
    sadToNeut = resample(sadToNeut, newlen, length(sadToNeut));
    neutToHappy = resample(neutToHappy, newlen, length(neutToHappy));
    neutToSad = resample(neutToSad, newlen, length(neutToSad));
    
    %apply those pitch windows to get new sounds
    disp('Creating Transformed Audio Files...0/6');
    hiHappyToSad = transformPitch(hiHappy, happyToSad, fs);
    disp('1/6');
    hiHappyToNeut = transformPitch(hiHappy, happyToNeut, fs);
    disp('2/6');
    hiNeutToHappy = transformPitch(hiNeut, neutToHappy, fs);
    disp('3/6');
    hiNeutToSad = transformPitch(hiNeut, neutToSad, fs);
    disp('4/6');
    hiSadToHappy = transformPitch(hiSad, sadToHappy, fs);
    disp('5/6');
    hiSadToNeut = transformPitch(hiSad, sadToNeut, fs);
    disp('6/6...Done!');
    
    %Write them out to audio files
    destdir = 'Audio_Sources';
    
    disp('Writing transformed audio to files....0/6');
    audiowrite(fullfile(pwd, destdir, 'Hi_Happy_To_Sad.wav'), ...
        hiHappyToSad, fs);
    disp('1/6');
    audiowrite(fullfile(pwd, destdir, 'Hi_Happy_To_Neut.wav'), ...
        hiHappyToNeut, fs);
    disp('2/6');
    audiowrite(fullfile(pwd, destdir, 'Hi_Neut_To_Happy.wav'), ...
        hiNeutToHappy, fs);
    disp('3/6');
    audiowrite(fullfile(pwd, destdir, 'Hi_Neut_To_Sad.wav'), ...
        hiNeutToSad, fs);
    disp('4/6');
    audiowrite(fullfile(pwd, destdir, 'Hi_Sad_To_Happy.wav'), ...
        hiSadToHappy, fs);
    disp('5/6');
    audiowrite(fullfile(pwd, destdir, 'Hi_Sad_To_Neut.wav'), ...
        hiSadToNeut, fs);
    disp('6/6...Done!');
    
    
    %% Set 'finished' boolean
    preProcessed = true;
