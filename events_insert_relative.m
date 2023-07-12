% EEG = insert_events_relative(EEG, newmarker, anchor, relpos[, repeat, altepochmethod])
%
%       Inserts new events at a given latency relative to existing events,
%       optionally repeating the new event a number of times at the same
%       indicated interval.
%
%       CAUTION: Behaviour of some of the underlying EEGLAB functions has
%                changed between different versions of EEGLAB. This script
%                can malfunction (without errors) on some versions when
%                calling it on epoched datasets. Try the 'altepochmethod'
%                argument if this happens.
%
% In:
%       EEG - EEGLAB dataset containing event information
%       newmarker - string giving the type of the new event
%       anchor - string or cell of strings giving the existing event types
%       relpos - relative position in seconds for the new events
%
% Optional:
%       repeat - number of times the event should be repeated, every
%                relpos; default: 1
%       altepochmethod - alternative method to use on epoched data that
%                        calls eeg_point2lat in a different way. as
%                        documented, this appears to be the correct way to
%                        call it for epoched data, but it does not produce
%                        correct results, seemingly dependent on the exact
%                        EEGLAB version in use. default: false
%
% Out:
%       EEG - EEGLAB dataset with new events added
%
% Usage example:
%       >> EEG = insert_events_relative(EEG, 'newevent', {'event1', ...
%                                       'event2'}, -.5);
% 
%                       Laurens R. Krol
%                       Neuroadaptive Human-Computer Interaction
%                       Brandenburg University of Technology

% 2023-07-11 lrk
% - Made event repeating
% - Changed argument input order
% - Renamed to events_insert_relative
% 2020 First version

% Copyright 2020, 2023 Laurens R. Krol

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

function EEG = events_insert_relative(EEG, newmarker, anchor, relpos, repeat, altepochmethod)

if nargin < 6, altepochmethod = false; end
if nargin < 5, repeat = 1; end

% getting relative event latencies in data points
rellat = nan(1,repeat);
for r = 1:repeat
    rellat(r) = r * relpos * EEG.srate;
end

% getting anchor event indices
anchoridx = ismember({EEG.event.type}, anchor);

% getting new event latencies in data points
newlatencies = [EEG.event(anchoridx).latency]' + rellat;
newlatencies = reshape(newlatencies', 1, []);

% converting to seconds for importevent
if isfield(EEG.event, 'epoch')
    newlatencies = newlatencies - EEG.xmin * EEG.srate;
end

if altepochmethod
    epochs = reshape(repmat([EEG.event(anchoridx).epoch]', 1, repeat)', 1, []);
    newlatencies = eeg_point2lat(newlatencies, epochs, EEG.srate, [EEG.xmin, EEG.xmax], 1);
else
    newlatencies = eeg_point2lat(newlatencies, [], EEG.srate, [EEG.xmin, EEG.xmax], 1);
end

% inserting new events
if isfield(EEG.event, 'epoch')
    epochs = reshape(repmat([EEG.event(anchoridx).epoch]', 1, repeat)', 1, []);
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
