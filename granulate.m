%% Make a granular segment out of an audio file
%
%   Kiran Kumar | 17 May, 2016
%
%   Inputs:
%       x:              audio file to granulate
%       fs:             sampling rate of x
%       dur:            duration (in seconds) of granulated output
%       sizeAv:         average grain size in samples
%       density:        number of grains per second
%       sizeVar:        amount of grain size variation in samples
%       offsetVar:      maximum amount in samples by which each grain could 
%                           be offset
%
%   Output:
%       y:              granulated audio file
%
%==========================================================================
%
%   Example:
% 
%       [x, fs] = audioread('Audio_Sources/Hi_Happy.wav');
%       y = granulate(x, fs, 12, 6000, 2000, 55, 8500);
%       - Create a 12-second stream of grains based on Hi_Happy.wav. Grains
%       will have an average size of 6000 samples with a random variation
%       of +- 2000 samples. Density is 55 grains/sec, and each grain has a
%       random starting delay between 0 and 85000 samples.
%
function y = granulate(x, fs, dur, sizeAv, sizeVar, density, offsetVar)
    
    x = mean(x, 2); %force to mono
    
    %% Error Checking
    
    %Average grain size can't be bigger than the audio file itself
%     curSize = min(sizeAv, length(x));
    if (sizeAv > length(x))
        warning(['sizeAv (', num2str(sizeAv), ') too large. Resetting to length(x): ',...
            num2str(length(x))]);
        sizeAv = length(x);
    end
    
    %Prevent size variations that are too large
    if (sizeVar >= sizeAv)
        warning(['sizeVar (', num2str(sizeVar), ') can''t exceed or equal sizeAv (', ... 
            num2str(sizeAv), '). Setting sizeVar = sizeAv - 1']);
        sizeVar = sizeAv - 1;
    end

    y = zeros(dur * fs, 1);
    
    %calculates hopsize based on desired grain density
    hopsize = round(fs / density);
    
    %% Create the grains
    for i = 1:hopsize:length(y)
        %account for size varation
        sizeOffset = round( rand(1) * 2 * sizeVar - sizeVar );
        curSize = sizeAv + sizeOffset;
        %Still...don't let the grain size exceed the size of the audio
        %   itself
        if (curSize > length(x))
            curSize = length(x);
        end
        
        stOutIx = i;
        endOutIx = stOutIx + curSize - 1;
        
        %account for index out of bounds
        if (endOutIx > length(y) )
            endOutIx = length(y);
            curSize = endOutIx - stOutIx + 1;
        end
        
        stGrainIx = mod(stOutIx, length(x) ); %relate the starting point in the output
            %to the starting point in the input audio. This loops the audio
            %if necessary
        
        %Create the grain with a random starting offset determined by 
        %   offsetVar parameter
        curGrain = makeGrain(x, curSize, stGrainIx + round(rand(1)*offsetVar));    
        y(stOutIx : endOutIx) = y(stOutIx : endOutIx) + curGrain;
    end
end
