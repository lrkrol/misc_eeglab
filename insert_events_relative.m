% insert_events_relative(EEG, anchor, relpos, newmarker)
%
%       Inserts new events at a given latency relative to existing events.
%
%       CAUTION: Behaviour of some of the underlying EEGLAB functions has
%                changed between different versions of EEGLAB. This script
%                can malfunction (without errors) on older versions when
%                calling it on epoched datasets. It has been written with
%                EEGLAB 2019.1.
%
% In:
%       EEG - EEGLAB dataset containing event information
%       anchor - string or cell of strings giving the existing event types
%       relpos - relative position in seconds for the new events
%       newmarker - string giving the type of the new event
%
% Out:
%       EEG - EEGLAB dataset with new events added
%
% Usage example:
%       >> EEG = insert_events_relative(EEG, {'event1', 'event2'}, -.5, ...
%                                       'newevent')
% 
%                       Laurens R. Krol
%                       Neuroadaptive Human-Computer Interaction
%                       Brandenburg University of Technology

% Copyright 2020 Laurens R. Krol

% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:

% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.

% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

function EEG = insert_events_relative(EEG, anchor, relpos, newmarker)

% getting anchor event indices
anchoridx = ismember({EEG.event.type}, anchor);

% getting new event latencies in datapoints
newlatencies = [EEG.event(anchoridx).latency] + EEG.srate * relpos;

% converting to seconds for importevent
if isfield(EEG.event, 'epoch')
    epochs = [EEG.event(anchoridx).epoch];
    newlatencies = eeg_point2lat(newlatencies, epochs, EEG.srate, [EEG.xmin, EEG.xmax], 1);
else
    newlatencies = eeg_point2lat(newlatencies, [], EEG.srate, [EEG.xmin, EEG.xmax], 1);
end

% inserting new events
if isfield(EEG.event, 'epoch')
    for i = 1:numel(newlatencies)
        EEG.event = importevent({newmarker, newlatencies(i), 1/EEG.srate, epochs(i)}, EEG.event, EEG.srate, 'fields', {'type', 'latency', 'duration', 'epoch'}, 'append', 'yes');
    end
else
    for lat = newlatencies
        EEG.event = importevent({newmarker, lat, 1/EEG.srate}, EEG.event, EEG.srate, 'fields', {'type', 'latency', 'duration'}, 'append', 'yes');
    end
end

% reporting
fprintf('inserted %d ''%s'' events\n', numel(newlatencies), newmarker);

% resorting events
EEG = eeg_checkset(EEG, 'eventconsistency');

end
