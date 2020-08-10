% [EEG, numbalanced] = balance_events(EEG, eventtypes [, ignoredlabel])
%
%       Balances the number of indicated events in an EEGLAB dataset by
%       randomly relabelling events from the larger classes.
%
% In:
%       EEG - EEGLAB dataset containing event information
%       eventtypes - 1-by-n cell of strings indicating event types, n > 1
%
% Optional:
%       ignoredlabel - string indicating the type of ignored events after
%                      relabelling; default 'ignoredevent'
%
% Out:
%       EEG - balanced EEGLAB dataset with relabelled events
%       numbalanced - the number of events left in the balanced dataset for
%                     each of the indicated event types
%
% Usage example:
%       >> EEG = balance_events(EEG, {'event1', 'event2'})
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

function [EEG, numbalanced] = balance_events(EEG, eventtypes, ignoredlabel)

if nargin < 3, ignoredlabel = 'ignoredevent'; end

% counting occurrences and saving indices
numevents = [];
eventidx = {};
for e = eventtypes
    numevents = [numevents, sum(strcmp(e, {EEG.event.type}))];
    eventidx = [eventidx; find(strcmp(e, {EEG.event.type}))];
end

if any(~numevents)
    error('event type ''%s'' not found', eventtypes{find(~numevents)});
end

numbalanced = min(numevents);

% taking random sample of indices to ignore
ignoreidx = [];
for ie = 1:numel(eventtypes)
    if numevents(ie) > numbalanced
        ignoreidx = [ignoreidx, randsample(eventidx{ie}, numevents(ie)-numbalanced)];
    end
end

% relabelling events
[EEG.event(ignoreidx).type] = deal(ignoredlabel);

% reporting
eventprint = repmat('''%s'', ', 1, numel(eventtypes)-1);
fprintf(['relabelled %d events; left %d each of ' eventprint '''%s''\n'], numel(ignoreidx), numbalanced, eventtypes{1:end-1}, eventtypes{end});

end