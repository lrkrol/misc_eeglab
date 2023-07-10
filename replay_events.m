% replay_events(EEG[, eventtypes])
%
%       Outputs the events in a dataset to the console, either by manual
%       progression, or at a given speed relative to the real timing.
%
% In:
%       EEG - the EEG dataset containing event information
%       speed - the speed with which to replay the events, with 1 being
%               real time, 2 twice as fast etc., and 0 manual progression.
%
% Optional:
%       eventtypes - a 1-by-n cell of strings indicating event types to
%                    include. other events will be ignored.
%
% Usage example:
%       >> count_events(EEG, {'event1', 'event3'});
% 
%                    Laurens R. Krol, 2021
%                    Neuroadaptive Human-Computer Interaction
%                    Brandenburg Univesity of Technology

% 2021-09-03 First version

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

function replay_events(EEG, speed, eventtypes)

% getting relevant event indices
if nargin < 3
    idx = 1:numel(EEG.event);
else
    idx = find(ismember({EEG.event.type}, eventtypes));
end

fprintf('      time   event\n');
for i = idx
    % showing event
    fprintf('%8.2f s   %s\n', EEG.event(i).latency/EEG.srate, EEG.event(i).type);
    
    % pausing
    if i ~= idx(end)
        if speed == 0
            pause;
        else
            pause((EEG.event(i+1).latency - EEG.event(i).latency) / EEG.srate / speed);
        end
    end
end

end
