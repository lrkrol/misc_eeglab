% EEG = photo2event(EEG, channel, varargin)
%
%       Takes an EEGLAB dataset that includes a photodiode channel and
%       transforms the onsets/offsets of this photodiode into event
%       markers. Assumes onsets result in rapid positive deflections, and
%       offsets in rapid negative deflections.
%
%       Use the plot argument to inspect the results of this script. The
%       threshold and refractory_period may need to be adjusted to work
%       with your data.
%
%       This script is based on bemobil_create_peak_events.m, part of the
%       BeMoBIL Pipeline, by Marius Klug.
%
% In:
%       EEG - EEGLAB dataset that includes a photodiode channel
%       channel - the number of the photodiode channel
%
% Optional inputs (key-value pairs):
%       lock - 'onset' or 'offset', indicating whether or not to create
%              events when the sensor detects visual onsets or offsets
%       threshold - the threshold to use when determining what counts as
%                   onset/offset. this scripts takes the derivative of the 
%                   photosensor channel data to determine sudden changes in
%                   channel activity, i.e., stimulus onsets and offsets.
%                   one such event is marked whenever a sample of the
%                   derivative data is past a threshold, set relative to
%                   the overall peak of the derivative data. default: .75
%       refractory_period - time in ms after a detected peak that no other
%                           peak is allowed to be detected. use this e.g.
%                           to ignore the jitter that can happen at high
%                           sampling rates, where the diode registers the
%                           on/off cycle of the display itself. default: 50
%       plot - whether or not to plot the derivative data, markers, and the
%              threshold, for inspection of the output (0|1, default: 0)
%       ignore - array of peak event indices to ignore; these peak events
%                will not result in event markers. numbers can be taken
%                from the plot created using the plot option (default: [])
%
% Out:  
%       EEG - the EEGLAB dataset with added markers
% 
%                    Copyright 2018 Marius Klug, Laurens R Krol
%                    Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-10-22 lrk
% - Updated plot and feedback to represent ignored events
% 2018-08-21 lrk
% - Fixed issue when two samples had the same peak value
% 2018-08-01 Changes by lrk from original by mk:
% - Now uses channel data derivative rather than component data
% - Added 'lock' parameter specific to photosensor use
% - Added stand-alone code to add events
% - Added plot
% - Added 'ignore' parameter

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


function EEG = photo2event(EEG, channel, varargin)

% parsing input
p = inputParser;

addRequired(p, 'EEG', @isstruct);
addRequired(p, 'channel', @isnumeric);

addParameter(p, 'lock', 'onset', @ischar);
addParameter(p, 'threshold', 0.75, @isnumeric);
addParameter(p, 'refractory_period', 50, @isnumeric);
addParameter(p, 'plot', 0, @isnumeric);
addParameter(p, 'ignore', 0, @isnumeric);

parse(p, EEG, channel, varargin{:})

EEG = p.Results.EEG;
channel = p.Results.channel;
lock = p.Results.lock;
threshold = p.Results.threshold;
refractory_period = p.Results.refractory_period;
plotdata = p.Results.plot;
ignore = p.Results.ignore;

if strcmp(lock, 'onset')
    % when locking to stimulus onset, all signals greater than the
    % threshold are relevant, and the peak is the maximum value
    past_threshold = @gt;
    peak = @max;
elseif strcmp(lock, 'offset')
    % when locking to stimulus offset, all signals smaller than the
    % threshold are relevant, and the peak is the minimum value
    past_threshold = @lt;
    peak = @min;
end

signal = diff(EEG.data(channel,:));
threshold = peak(signal) * threshold;

fprintf('Looking for peaks...\n');

event_latencies = [];
timepoint = 1;

while timepoint <= length(signal)
    
    if past_threshold(signal(timepoint), threshold)
        % peak detected        
        starting_timepoint = timepoint;
        
        % find the end of this peak's activity - this is defined as half
        % the threshold to ensure that the activity is actually down to
        % normal and not just fluctuating around the threshold.
        while past_threshold(signal(timepoint), threshold*0.5)
            timepoint = timepoint + 1;
        end
        ending_timepoint = timepoint;
        
        maximum_timepoint = starting_timepoint - 1 + ...
            find(signal(starting_timepoint:ending_timepoint) == ...
            peak(signal(starting_timepoint:ending_timepoint)), 1);
        
        event_latencies(end+1) = maximum_timepoint; %#ok<AGROW>
        
        if ~isempty(refractory_period)            
            % add minimum duration (in ms) to the maximum timepoint and
            % continue from there
            timepoint = maximum_timepoint + round((refractory_period/(1/EEG.srate))/1000);
        end
    else
        % no peak detected
        timepoint = timepoint + 1;        
    end
    
end

fprintf('Found %d event(s)\n', numel(event_latencies));

if ~isfield(EEG, 'event')
    % creating new empty event structure
    EEG.event = struct('type', {}, 'latency', {}, 'duration', {});
end

% adding peak event markers
added = 0;
for l = 1:numel(event_latencies)
    if ismember(l, ignore), continue; end
    i = numel(EEG.event) + 1;
    EEG.event(i).type = ['photo-' lock];
    EEG.event(i).latency = event_latencies(l);
    EEG.event(i).duration = 1/EEG.srate;
    added = added + 1;
end
fprintf('Added %d marker(s)\n', added);

EEG = eeg_checkset(EEG, 'eventconsistency');

if plotdata
    fprintf('Generating plot...\n');
    figure('Color', 'white'); hold on;
    set(findobj(gcf, 'type','axes'), 'Visible', 'off')
    
    % signal derivative
    s = plot(signal, 'r');
    
    ylim = get(gca,'ylim');
    xlim = get(gca,'xlim');
    
    % detected events
    for l = 1:numel(event_latencies)
        if ismember(l, ignore)
            line([event_latencies(l) event_latencies(l)], ylim, 'Color', [.8 .8 .8], 'LineStyle', '--');
        else
            line([event_latencies(l) event_latencies(l)], ylim, 'Color', [.8 .8 .8]);
        end
        text(event_latencies(l), ylim(2), num2str(l), 'HorizontalAlignment', 'center', 'Color', [.8 .8 .8], 'BackgroundColor', 'white');
        text(event_latencies(l), ylim(1), num2str(l), 'HorizontalAlignment', 'center', 'Color', [.8 .8 .8], 'BackgroundColor', 'white');
    end
    
    uistack(s, 'top');
    
    % zero
    line(xlim, [0 0], 'Color', 'black');
    text(xlim(1), 0, '0', 'HorizontalAlignment', 'center', 'Color', 'black', 'BackgroundColor', 'white');
    
    % threshold
    line(xlim, [threshold, threshold], 'Color', 'black');
    text(xlim(1), double(threshold), 'threshold', 'HorizontalAlignment', 'right', 'Color', 'black', 'BackgroundColor', 'white');
end

end