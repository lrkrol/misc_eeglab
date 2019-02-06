% EEG = utl_create_eeglabdataset(data, srate, varargin)
%
% In:
%       data - channels x samples matrix of data points for continuous data
%              or channels x samples x epochs matrix of data points for
%              epoched data
%       srate - the sampling rate of the data
%
% Optional (key-value pairs):
%       chanlocs - an EEGLAB chanlocs structure
%       chanlabels - a cell array of channel labels; ignored when chanlocs
%                    is indicated
%       xmin - epoch start latency in seconds for epoched data, relative
%              to the time-locking event at time 0, i.e., should be <= 0
%              (default 0)
%       marker - string to put at 0 time point for epoched data (default
%                'event')
%
% Out:  
%       EEG - dataset in EEGLAB format
%
% Usage example:
%       >> EEG = utl_create_eeglabdataset(rand(3, 512, 100), 512, ...
%          'chanlabels', {'C1', 'C2', 'C3'}, 'xmin', -0.2)
% 
%                    Copyright 2015-2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-14 lrk
%   - Now accepts both chanlocs structure and cell of channel labels
%   - Added markers
%   - Switched to inputParser to parse arguments
% 2015-11-30 First version

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


function EEG = create_EEGLABdataset(data, srate, varargin)

% parsing input
p = inputParser;

addRequired(p, 'data', @isnumeric);
addRequired(p, 'srate', @isnumeric);

addParamValue(p, 'chanlocs', [], @isstruct);
addParamValue(p, 'chanlabels', [], @iscell);
addParamValue(p, 'xmin', 0, @isnumeric);
addParamValue(p, 'marker', 'event', @ischar);

parse(p, data, srate, varargin{:})

data = p.Results.data;
srate = p.Results.srate;
chanlocs = p.Results.chanlocs;
chanlabels = p.Results.chanlabels;
xmin = p.Results.xmin;
marker = p.Results.marker;

% creating required fields and corresponding values where available
EEG = struct(); 

EEG.setname = '';
EEG.filename = '';
EEG.filepath = '';

EEG.nbchan = size(data, 1);
EEG.trials = size(data, 3);
EEG.pnts = size(data, 2);
EEG.srate = srate;
EEG.xmin = xmin;
EEG.xmax = EEG.xmin + (EEG.pnts-1) / EEG.srate;
EEG.data = data;

EEG.icaact = [];
EEG.icawinv = [];
EEG.icaweights = [];
EEG.icasphere = [];

% adding channel info
if ~isempty(chanlocs)
    EEG.chanlocs = chanlocs;
else
    EEG.chanlocs = struct();
    for c = 1:EEG.nbchan
        if ~isempty(chanlabels)
            EEG.chanlocs(c).labels = chanlabels{c};
        else
            EEG.chanlocs(c).labels = num2str(c);
        end
        EEG.chanlocs(c).urchan = c;
    end
end

[EEG.chanlocs.type] = deal('EEG');
[EEG.chanlocs.X] = deal([]);
[EEG.chanlocs.Y] = deal([]);
[EEG.chanlocs.Z] = deal([]);
[EEG.chanlocs.sph_theta] = deal([]);
[EEG.chanlocs.sph_phi] = deal([]);
[EEG.chanlocs.sph_radius] = deal([]);
[EEG.chanlocs.theta] = deal([]);
[EEG.chanlocs.radius] = deal([]);
[EEG.chanlocs.ref] = deal('');

EEG = eeg_checkset(EEG);

if EEG.trials > 1
    % adding markers
    EEG.event = struct('type', {}, 'latency', {}, 'duration', {}, 'epoch', {}, 'init_index', {}, 'init_time', {});
    for e = 1:EEG.trials
        EEG.event(e) = importevent( ...
                {marker, -xmin + (e-1) * EEG.pnts/EEG.srate, 1/EEG.srate, e}, ...
                [], EEG.srate, ...
                'fields', {'type', 'latency', 'duration', 'epoch'});
    end
    
    EEG = eeg_checkset(EEG, 'eventconsistency');
end

end