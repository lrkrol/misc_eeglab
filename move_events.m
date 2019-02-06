% [EEG, diffs] = move_events(EEG, moveevents, targetevents)
%
%       Moves indicated events forward in time to have the same 
%       latency as the nearest target event.
%
%       Note that events are indicated as regular expressions and the
%       script will move all matches. Use the OR operator to indicate
%       multiple events, e.g. 'event1|event2|event3', or wildcards, e.g.
%       'event*'.
%
% In:
%       EEG - EEGLAB dataset with event structure
%       moveevents - regular expression representing the event types
%                    (markers) of the events that are to be moved
%       targetevents - regular expression representing the event types
%                      (markers) of the events to which earlier events are
%                      to be moved
%
% Out:
%       EEG - the updated EEGLAB dataset
%       diffs - array of latency differences for the moved markers, in ms
%
%                    Copyright 2019 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology
%
% Usage example:
%       To move events 'A10', 'A15', and 'B10' forward to 'photo-onset'
%       while ignoring 'B15':
%       >> [EEG, diffs] = move_events(EEG, 'A1*|B10', 'photo-onset');

% 2019-02-04 First version

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


function [EEG, diffs] = move_events(EEG, moveevents, targetevents)

% sorting events
if isfield(EEG.event, 'epoch')
    EEG = pop_editeventvals(EEG, 'sort', { 'epoch' 0 'latency' 0 });
else
    EEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });
end

diffs = [];
misses = 0;
for e = 1:length(EEG.event)
    % finding indicated events
    if regexp(EEG.event(e).type, moveevents)        
        % finding earliest following target event
        counter = 1;
        while isempty(regexp(EEG.event(e + counter).type, targetevents, 'once'))
            counter = counter + 1;
            if e + counter > length(EEG.event)
                warning('could not find target event for event number %d, %s', e, EEG.event(e).type);
                misses = misses + 1;
                break
            end
        end
        
        if e + counter > length(EEG.event)
            % no target event found; continuing on to next event
            continue
        else
            % updating event latency
            diffs = [diffs, EEG.event(e + counter).latency - EEG.event(e).latency];
            EEG.event(e).latency = EEG.event(e + counter).latency;
        end
    end
end

% sorting events again
if isfield(EEG.event, 'epoch')
    EEG = pop_editeventvals(EEG, 'sort', { 'epoch' 0 'latency' 0 });
else
    EEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });
end

EEG = eeg_checkset(EEG);

% converting diffs to ms
diffs = 1000 .* diffs ./ EEG.srate;

fprintf('moved %d events an average of %.3f ms\n', numel(diffs), mean(diffs));
if misses > 0, fprintf('could not move %d events\n', misses); end

end
