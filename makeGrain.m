%% Make a single grain out of a sound file
%
%   Kiran Kumar | 17 May, 2016
%
%   Inputs:
%       x:              the original audio file
%       len:            length of the grain in samples
%       L:              [OPTIONAL] number of samples by which to delay the 
%                       starting point
%                           default = 0
%               NOTE: If len and L create a grain that would pass the end
%               of the raw audio file, the remainder of the grain loops
%               back around to the beginning of the raw audio
%       winType:        [OPTIONAL] handle to a window function to use on 
%                       the grain
%                           default = @hamming
%
%   Output:
%       y:              the single sound grain
%
%==========================================================================
%
%   Example:
% 
%       [x, fs] = audioread('Audio_Sources/Hi_Happy.wav');
%       y = makeGrain(x, 9500, 3333, @blackman);
%       - create a 9500-sample grain out of Hi_Happy.wav, starting at 3333
%       samples delayed and applying a blackman window (overriding the
%       default hamming window)
%
function  y = makeGrain(x, len, L, winType)
    %% Error Checking
    if (nargin < 2)
        error('You must enter an input signal ''x'' and length ''len''');
    end

    if (nargin < 3)
     L = 0;
    end

    if (nargin < 4)
        winType = @hamming;
    end

    % Need positive sample delay
    if (L < 0)
        error('You must enter a positive sample delay ''L''');
    end
    
    % Account for if the sample delay entered is beyond a full cycle of the
    % audio
    if (L > length(x))
        warning(['Setting L to mod(', num2str(L), ',', num2str(length(x)), ...
            ') = ', num2str(mod(L, length(x))) ]);
        L = mod(L, length(x) );
    end
    
    % Force the grain to not be larger than the raw audio
    if (len > length(x))
        warning('Grain size ''len'' must be <= the length of your input audio ''x''');
        warning('Resetting ''len'' to length(x)');
        len = length(x);
    else
        
    end
    
    %% Initialization
    y = zeros(len, 1);
    
    %% Processing
    
    % Extract the grain
    stIx = 1 + L;
    endIx = stIx + len - 1;
    
    %Loop back around if necessary
    if (endIx > length(x))
        %do the ending part of x first
        firstSegLen = length(x) - stIx + 1;
        y(1 : firstSegLen) = x(stIx : length(x));
        %now do the beginning of x (the part that loops back around)
        y(firstSegLen + 1 : len) = x(1 : (len - firstSegLen) );
    else
        y = x(stIx : endIx);
    end
    
    % Window the grain
    mywin = window(winType, length(y));
    y = y .* mywin;
    
end