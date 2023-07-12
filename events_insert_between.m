% EEG = events_insert_between(EEG, newmarker, startmarker, endmarker, seconds, margin)
%
%       Inserts events every x seconds between a startmarker and the first
%       of the subsequent endmarkers, starting at startmarker and ending no
%       later than "margin" seconds before the endmarker
%
% In:
%       EEG - EEGLAB dataset containing event information
%       newmarker - string giving the type of the new event
%       startmarker - string giving the type of the existing event after
%                     which the new events should be added
%       endmarker - string giving the type of the existing event until
%                   which the new events should be added
%       seconds - number indicating the time in seconds between the
%                 startmarker and beween each newmarker to be added
%       margin - number indicating the latest time in seconds before the 
%                endmarker at which to stop adding markers; e.g. 2 means
%                that no newmarker will appear later than 2 seconds before
%                each endmarker
%
% Out:
%       EEG - EEGLAB dataset with new events added
%
% Usage example:
%       >> EEG = events_insert_between(EEG, 'newmarker', 'event1', ...
%          'event2', .5, .5);
% 
%                       Laurens R. Krol
%                       Neuroadaptive Human-Computer Interaction
%                       Brandenburg University of Technology

% 2020 First version

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

function EEG = events_insert_between(EEG, newmarker, startmarker, endmarker, seconds, margin)

    % finding start latencies
    startidx = find(strcmp(startmarker, {EEG.event.type}));
    startlatencies = [EEG.event(startidx).latency];
    
    % finding corresponding end latencies
    endidx = [];
    for s = startidx
        e = s+1;
        while ~any(strcmp(EEG.event(e).type, endmarker))
            e = e + 1;
        end
        endidx = [endidx, e];
    end
    endlatencies = [EEG.event(endidx).latency];
    
    if numel(startlatencies) ~= numel(endlatencies)
        error('could not match all markers');
    end
    
    % finding latencies to insert new markers
    newlatencies = [];
    for l = 1:numel(startlatencies)
        newlatency = startlatencies(l);
        while newlatency < endlatencies(l) - margin*EEG.srate
            newlatencies = [newlatencies, newlatency];
            newlatency = newlatency + seconds*EEG.srate;
        end
    end
    
    % inserting new markers
    for e = 1:numel(newlatencies)
        EEG.event = importevent( ...
                {newmarker, newlatencies(e), 1}, ...
                EEG.event, EEG.srate, ...
                'fields', {'type', 'latency', 'duration'}, ...
                'timeunit', NaN);
    end
    
    fprintf('Added %d events.\n', numel(newlatencies));
    
    % re-sorting events
    EEG = eeg_checkset(EEG, 'eventconsistency');
    EEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });

end
