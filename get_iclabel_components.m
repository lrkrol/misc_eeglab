% get_iclabel_components(EEG, type [, threshold])
%
%       Returns the indices of components which ICLabel has classified as
%       a certain type. When a threshold is indicated between 0 and 1, all
%       components which have an above-threshold probability of belonging
%       to the indicated type are returned. If no threshold is indicated,
%       all components are returned for which the indicated type's
%       probability is higher than the other probabilities.
%
%       This script was written with ICLabel 1.2.6.
%
% In:
%       EEG - EEGLAB dataset containing ICLabel classifications
%       type - the type of component to look for. this can be:
%              'brain', or 1
%              'muscle', or 2
%              'eye', or 3
%              'heart', or 4
%              'line', 'linenoise', or 5
%              'channel', 'channelnoise', or 6
%              'other', or 7
%
% Optional:
%       threshold - type probability threshold value between 0 and 1.
%                   default: relative majority is used instead of threshold
%
% Out:
%       idx - the indices of the selected components
%       otheridx - the indicates of all other components
%
% Usage example:
%       >> EEG = get_iclabel_components(EEG, 'brain', 2/3)
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

function [idx, otheridx] = get_iclabel_components(EEG, type, threshold)

if nargin == 2, threshold = []; end

% testing if ICLabel classifications are present
if ~isfield(EEG.etc, 'ic_classification'), error('no field EEG.etc.ic_classification;\nrun ICLabel first'); end

% setting type
if isnumeric(type) && floor(type) == type
    if type > 7, error('unknown type: %d', type); end
elseif ischar(type)
    switch type
        case 'brain', type = 1;
        case 'muscle', type = 2;
        case 'eye', type = 3;
        case 'heart', type = 4;
        case 'line', type = 5;
        case 'linenoise', type = 5;
        case 'channel', type = 6;
        case 'channelnoise', type = 6;
        case 'other', type = 7;
        otherwise, error('unknown type: %s', type);
    end
else
    error('unknown type');
end

if isempty(threshold)
    % components where the requested type has the highest probability
    [~, i] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2);
    idx = find(i == type);
else
    % components where the requested type is above the threshold
    idx = find(EEG.etc.ic_classification.ICLabel.classifications(:,type) > threshold);
end

% separately returning all other components
otheridx = setdiff(1:size(EEG.icaweights,1), idx);

end
