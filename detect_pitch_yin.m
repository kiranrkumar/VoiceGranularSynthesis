%% Calculate pitch using the yin method
%   - Modified version of my MIR assignment 3 from Spring, 2015
%
%   Kiran Kumar | 17 May, 2016
%
% Parameters 
% ----------
% x_t : 1 x T array
%   time domain signal 
% fs : int
%   sample rate (samples per second) 
% win_size : int
%   window size (in samples) 
% hop_size : int
%   hop size (in samples) 
% min_lag : int
%   minimum possible lag value (in samples) 
% max_lag : int
%     maximum possible lag value (in samples)
% Returns
% ------- 
% pitch : 1 x P array
%   detected pitch values (Hz) 
% t_pitch : 1 x P array
%   time points in seconds
% yinVals : 1 x P array
%   yin values
%
%==========================================================================
%
%   Example:
% 
%       [x, fs] = audioread('Audio_Sources/Hi_Happy.wav');
%       [pitch, t_pitch, yinVals] = detect_pitch_yin(x, fs, 1024, 512, ...
%           120, 1102);
%           - returns a pitch contour vector of Hi_Happy.wav, limiting the
%           frequency search range between fs/1102 (40.02) Hz and fs/120
%           (367.5) Hz
%
function [pitch, t_pitch, yinVals] = detect_pitch_yin(x_t, fs, win_size, hop_size, min_lag, max_lag)
%
% Yin function
%
%   d(l) = ( 1 / (N - l) ) * ?[n=0 : N - 1 - l] ( x(n) - x(n + l) )^2
%       l = 0:1:(L - 1)
%   dHat(l) --> (if l == 0), = 1, else = ( d(l) / ( (1 / l) * SIG[u =
%       0:1:l] d(u) ) )

    % to account for MATLAB index start at 1 issue
    min_lag = min_lag + 1;
    max_lag = max_lag + 1;
    
    %initialize vector of yin value outputs
    yinVals = [];

    % index for output arrays
    pitch_Ix = 1;
    
    dl = zeros(1, max_lag);
    dHat = zeros(1, max_lag);
    
    % traverse the entire signal, increasing by hop_size
    for m = 1:hop_size:(length(x_t) - win_size - max_lag)
        
        % reset yin-per-window arrays
        dl(:) = 0;
        dHat(:) = 0;
        
        % loop through all time delays 'l'
        for l = min_lag:max_lag
            
            % for each window
            for n = m:(m + win_size - l - 1)
                % calculate the yin for the lag value
                dl(l) = dl(l) + ( x_t(n) - x_t(n + l) )^2;
            end
            
            % Normalize and remove lag bias
            if (l == 1)
                dHat(l) = 1;
            else
                dHat(l) = dl(l) / ( (1 / l) * sum( dl(1:l) ) );
            end
            
        end
        
        % find the min of all yins in the current window
        [yinVal, sample_Ix] = min(dHat(min_lag:max_lag)); 
        yinVals(end+1) = yinVal;
        
        % Threshold so that silent regions don't go crazy
        %if (yinVal < 0.5)
            
            % account for index offset in above min function
            sample_Ix = sample_Ix + min_lag;
            
            % convert sample index to frequency to store in pitch array
            T = (sample_Ix) / fs;
            pitch(pitch_Ix) = 1/T;
            
            % convert time index of the yin to seconds
            t_pitch(pitch_Ix) = (sample_Ix + m) / fs;
         
            %Override for high yin values
            if (yinVal > 0.72)
                pitch(pitch_Ix) = 0;
            end
        %end
            % increment output array index
            pitch_Ix = pitch_Ix + 1;
           
        
    end
end