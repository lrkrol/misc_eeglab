% alias due to change in function naming scheme

function varargout = get_events_timelocked(varargin)

   [varargout{1:nargout}] = events_get_timelocked(varargin{:});
   
end