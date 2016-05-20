% Kiran Kumar | 17 May 2016
%
% Implement overlap and add with time stretching
%
%   Inputs:
%       x:              [m x 1] time domain input signal
%       winlen:         [1 x 1] size of analysis window in samples
%       overlap:        [1 x 1] amount of overlap in samples between
%                   windows
%       compAmt:        [1 x 1] compression ratio
%                       - if > 1, compress the time
%                       - if < 1, stretch the time
%       hopRand:        [1 x 1] amount of randomization in hop size. In the
%                   range [0, 1]
%                       - if 0, no randomization
%                       - if 1, hop size can vary  between 1 sample and
%                         + or - (winlen-overlap)/2
%   Outputs:
%       y:              [n x 1] time stretched/compressed signal
%==========================================================================
%
%   Examples:
% 
%   TRY THIS:
%       [x, fs] = audioread('Audio_Sources/Hi_Happy.wav');
%       y = timeStretch(x, 1024, 512, 1.2, 0.4);
%           - compresses the sound in 'Audio_Sources/Hi_Happy.wav' by 20%
%           with a random synthesis hop size between ~-179 and ~+179 
%           samples (window length of 1024 samples and overlap of 512)
%
%       [x, fs] = audioread('Audio_Sources/Hi_Sad.wav');
%       y = timeStretch(x, 512, 256, 0.5, 0.05);
%           - stretches 'Audio_Sources/Hi_Sad.wav' to double the length 
%           with very little randomization of hop size. Win len = 512 and 
%           overlap = 256

%%
function y = timeStretch(x, winlen, overlap, compAmt, hopRand)
    
    %force x to mono
    x = mean(x, 2);
    
    %Analysis - buffer the input signal
    xBuff = buffer(x, winlen, overlap);
    
    numFrames = size(xBuff, 2);
    
    %window all of the analysis frames
    winvec = hann(winlen);
    winmat = repmat(winvec, 1, numFrames);
    xBuff = xBuff .* winmat;
    
    hopSize = winlen - overlap;
    
    %initialize output vector based on time compression amount and hop size
    %   randomization
    y = zeros( round( (winlen + (hopSize + hopSize*hopRand) * numFrames) / compAmt), 1);
    
    %Synthesis
    stIx = 1;
    endIx = stIx + winlen - 1;
    for n = 1:numFrames
        %zero pad to prevent out of bounds issues
        if (endIx > length(y))
            y(end+1:endIx) = 0;
        end
        
        %Add the current frame to the proper place within y
        y(stIx : endIx) = y(stIx : endIx) + xBuff(:, n);
       
        %set up indices for the next frame
        curHop = hopSize + round( (rand(1) * 2 - 1)*hopSize/2*hopRand ); %half of the variance
        %occurs above the standard hop size and the other half below the
        %hop size
        
        curHop = round( curHop / compAmt ); %apply time-stretched hop
        
        %Advance the indices
        stIx = stIx + curHop;
        endIx = stIx + winlen - 1;
    end
    
end