%% Pitch shift audio data by a certain scaling coefficient
%
%   Kiran Kumar | 17 May, 2016
%
%   Inputs:
%       x:              audio data
%       fs:             sampling rate of x
%       scale:          positive scaling coefficient. 2 doubles the
%                           audio's frequency, 0.5 cuts it in half, and 1
%                           keeps it where it is
%
%   Output:
%       y:              pitch-shifted audio data
%
%==========================================================================
%
%   Example:
% 
%       [x, fs] = audioread('Audio_Sources/Hi_Happy.wav');
%       y = pitchShift(x, fs, 0.75);
%       - pitch shift Hi_Happy.wav to 3/4 its original frequency
%
function y = pitchShift(x, fs, scale)
    %% Variables for time stretching and pitch shifting
    compAmt = 1/scale;
    winlen = 1024;
    overlap = winlen/2;
    hopRand = 0.8;

    %% Processing
    %Pitch shift: Resample the audio
    
    %for debugging purposes
    P = fs;
    Q = round(fs * scale);
    while (P * Q >= 2^31)
        P = round(P/2);
        Q = round(Q/2);
    end
    
    %Pitch shift: Resample the audio
    y = resample(x, P, Q );

    %Time stretch: apply OLA algorithm
    y = timeStretch(y, winlen, overlap, compAmt, hopRand);
end