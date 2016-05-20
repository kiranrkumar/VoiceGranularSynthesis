%% Main driver for VOGRE (VOice GRains with Emotion) granular synthesis engine
%
%   Kiran Kumar | 17 May, 2016
%
%% Preprocessing script
% Needed only once AND only if the Audio_Sources directory does not have
%   all 9 audio files(CAUTION: takes a while!)
% if (preProcessed) %checks for a variable set by the preprocessing script
%     disp('Preprocessing already completed. Skipping....');
% else
%     preProcessing;
% end

%Suppress warnings so MATLAB doesn't spew out a bunch of crap
warning('off', 'all');

%% Run the front end GUI
frontEnd;