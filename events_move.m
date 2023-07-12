% [EEG, diffs] = events_move(EEG, moveevents, target)
%
%       Given continuous data, moves indicated events, either 
%       - forward in time to have the same latency as the nearest
%         following specified target event, or
%       - a specified amount forward/backward in time.
%
%       Note that events are indicated as regular expressions and the
%       script will move all matches. Use the OR operator to indicate
%       multiple events, e.g. 'event1|event2|event3', or wildcards, e.g.
%       'event.+'. '.*' indicates all events. Also make sure to use anchors
%       where necessary: 'target' will match both 'target' and 'nontarget',
%       because the start-of-line anchor was left out. '^target' will not
%       match 'nontarget', but it will match 'targetasdf'. '^target$' will
%       match only 'target'.
%
% In:
%       EEG - EEGLAB dataset with event structure
%       moveevents - regular expression representing the event types
%                    (markers) of the events that are to be moved
%       target - if numeric: time in ms to shift the indicated events.
%                if string: regular expression representing the event types
%                (markers) of the events to which earlier events are to be
%                moved.
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
%       >> [EEG, diffs] = events_move(EEG, 'A1*|B10', 'photo-onset');
%
%       To move all events 150 ms forward in time:
%       >> [EEG, ~] = events_move(EEG, '.*', 150);

% 2023-07-12 lrk
%   - Renamed from move_events to events_move
% 2019-03-06 lrk
%   - Changed 'targetevents' to 'target', now also accepts numerical
%     time to shift events a specified amount
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


function [EEG, diffs] = events_move(EEG, moveevents, target)

% sorting events
if isfield(EEG.event, 'epoch')
    EEG = pop_editeventvals(EEG, 'sort', { 'epoch' 0 'latency' 0 });
else
    EEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });
end

diffs = [];
misses = 0;

if ischar(target)
    for e = 1:length(EEG.event)
        % finding indicated events
        if regexp(EEG.event(e).type, moveevents)        
            % finding earliest following target event
            counter = 1;
            while isempty(regexp(EEG.event(e + counter).type, target, 'once'))
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
elseif isnumeric(target)
    % getting latency difference
    latdiff = EEG.srate * target/1000;
    for e = 1:length(EEG.event)
        % finding indicated events
        if regexp(EEG.event(e).type, moveevents)
            if EEG.event(e).latency + latdiff <= EEG.pnts
                diffs = [diffs, EEG.event(e).latency + latdiff - EEG.event(e).latency];
                EEG.event(e).latency = EEG.event(e).latency + latdiff;
            else
                warning('cannot move event number %d, %s, out of range', e, EEG.event(e).type);
                misses = misses + 1;
            end
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
