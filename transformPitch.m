%% Apply a pitch contour/window to an audio file
%
%   Kiran Kumar | 17 May, 2016
%
%   Inputs:
%       x:              audio data
%       pitchWindow:    one-dimensional vector of pitch scaling
%                           coefficients. Scaling values are distributed
%                           evenly across time
%       fs:             sampling rate of x
%
%   Output:
%       out:              pitch-transformed audio data
%
%==========================================================================
%
%   Example:
% 
%       [x, fs] = audioread('Audio_Sources/Hi_Happy.wav');
%       pitchWin = 1:0.05:2;
%       out = transformPitch(x, pitchWin, fs);
%       - Apply a pitch window to Hi_Happy.wav such that its pitch
%       increases over time from 1x to 2x its original frequency.
%
function out = transformPitch(xin, pitchWindow, fs)
    
    %assume fs = 44100 if not specified
    if (nargin == 2)
        fs = 44100;
    end

    %figure out how many samples per pitch change
    samplesPerPitch = ceil( length(xin) / length(pitchWindow) );
    %zero pad to make this an exact multipl
    xin(end + 1 : length(pitchWindow) * samplesPerPitch) = 0;
    lenx = length(xin);
    
    %initialize out variable
    out = zeros( lenx, 1);
    
    %loop through each detected pitch - analyzed two blocks per detected
    %   pitch (to provide some overlap and minimize drastic AM effects)
    lenPitch = length(pitchWindow);
    for i = 1:lenPitch
        %get indices
        stIx = (i-1) * samplesPerPitch + 1;
        endIx = stIx + samplesPerPitch - 1;
        
        %apply pitch shifting to the appropriate part of the signal
        curShiftSig = pitchShift(xin(stIx:endIx), fs, pitchWindow(i));
        
        %update end index based on the pitch-shifted segment
        endIx = stIx + length(curShiftSig) - 1;
        
        %zero pad the output as needed
        if (endIx > length(out))
            out(end+1 : endIx) = 0;
        end
        
        %extract the relevant time indices
        out(stIx : endIx) = out(stIx : endIx) + curShiftSig;
        
        
    end
    
    %normalize
    out = out / max(abs(out));
    
end