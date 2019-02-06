% [count, eventtypes] = count_events(EEG[, eventtypes])
%
%       Counts the number of all or specified events in an EEG dataset, and
%       returns an array of these numbers plus a cell of the counted types.
%
% In:
%       EEG - the EEG dataset containing event information
%
% Optional:
%       eventtypes - a 1-by-n cell of strings indicating event types to
%                    count. other events will be ignored.
%
% Out:
%       count - array containing the number of events in the order as
%               listed in eventtypes
%       eventtypes - cell array of unique event types
%
% Usage example:
%       >> count_events(EEG);
%       >> count_events(EEG, {'event1', 'event2'})
% 
%                    Laurens R Krol, 2016, 2017, 2018
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-01-16 lrk
%   - Changed output from single struct to an array and a cell
% 2017-03-09 lrk
%   - Now returns struct with counts
% 2016-07-19 First version

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

function [count, eventtypes] = count_events(EEG, eventtypes)

allevents = {EEG.event.type};

% getting total count, and setting eventtypes if not given
if ~exist('eventtypes', 'var')
    eventtypes = sort(unique(allevents));
    fprintf('%d events of %d types\n', numel(allevents), numel(eventtypes));
else
    eventcount = 0;
    for i = 1:length(eventtypes)
        n = strcmp(eventtypes{i}, allevents);
        eventcount = eventcount + sum(n);
    end
    fprintf('%d events of %d selected types\n', eventcount, numel(eventtypes));
end

% getting type lengths for output formatting
strlengths = cellfun(@(x) numel(x), eventtypes);
longeststring = max(strlengths);
format = sprintf('%%%ds - %%5d\\n', longeststring);

% counting event types
count = nan(1, length(eventtypes));
for i = 1:length(eventtypes)
    n = strcmp(eventtypes{i}, allevents);
    count(i) = sum(n);
    fprintf(format, eventtypes{i}, sum(n));
end

end
