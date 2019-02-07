% events = get_events_timelocked(EEG)
%
%       Returns an array of event types around which the current dataset
%       was epoched. Useful when working with someone else's epoched data
%       and you don't know which epochs you're dealing with.
%
%       Note that when epoching, the epochs are time-locked at zero to the
%       selected events. When the epochs do not contain t=0, these events 
%       can obviously no longer be recovered.
%
% In:
%       EEG - epoched EEGLAB dataset
%
% Out:
%       events - cell of event types at t=0 for the given epochs
%
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology
%
% Usage example:
%       >> events = get_events_timelocked(EEG);

% 2018-02-21 First version

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


function events = get_events_timelocked(EEG)

firsteventlatency = EEG.srate * abs(EEG.xmin) + 1;

events = {};
latencies = [];
for e = 1:length(EEG.event)
    if mod(EEG.event(e).latency, size(EEG.data, 2)) == firsteventlatency
        events = [events, {EEG.event(e).type}];
        idx = find(latencies == EEG.event(e).latency);
        if idx
            fprintf('event %s and %s occur at the same time at sample %d', EEG.event(e).type, events{idx}, EEG.event(e).latency);
        end
        latencies = [latencies, EEG.event(e).latency];
    end
end

events = unique(events);

end
