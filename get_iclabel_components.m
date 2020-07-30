% get_iclabel_components(EEG, type [, threshold, rvthreshold])
%
%       Returns the indices of components which ICLabel has classified as
%       a certain type. When a threshold is indicated between 0 and 1, all
%       components which have an above-threshold probability of belonging
%       to the indicated type are returned. If no threshold is indicated,
%       all components are returned for which the indicated type's
%       probability is higher than the other probabilities. It is
%       additionally possible to exclude components with a residual
%       variance in their dipole model above a certain threshold.
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
%       threshold - type probability threshold value between 0 and 1, or []
%                   default [] uses relative majority instead of threshold
%       rvthreshold - residual variance threshold. if nonzero, components
%                     with a residual variance in their dipole model above
%                     the given threshold are excluded.
%
% Out:
%       idx - the indices of the selected components
%       invidx - the indices of all remaining components
%
% Usage example:
%       >> EEG = get_iclabel_components(EEG, 'brain', [], .15)
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


function [idx, invidx] = get_iclabel_components(EEG, type, threshold, rvthreshold)

if nargin < 3, threshold = []; end
if nargin < 4, rvthreshold = []; end

% testing if ICLabel classifications are present
if ~isfield(EEG.etc, 'ic_classification'), error('no field EEG.etc.ic_classification;\nrun ICLabel first'); end

% setting type
if isnumeric(type) && floor(type) == type
    if type < 1 || type > 7, error('unknown type: %d', type); end
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

if rvthreshold
    % removing components with a residual variance above rvthreshold
    idx = setdiff(idx, find([EEG.dipfit.model.rv] > rvthreshold));
end

% separately returning all nonselected components
invidx = setdiff(1:size(EEG.icaweights,1), idx);

end
