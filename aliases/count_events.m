% alias due to change in function naming scheme

function varargout = count_events(varargin)

   [varargout{1:nargout}] = events_count(varargin{:});
   
end