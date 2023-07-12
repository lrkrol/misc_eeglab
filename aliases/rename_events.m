% alias due to change in function naming scheme

function varargout = rename_events(varargin)

   [varargout{1:nargout}] = events_rename(varargin{:});
   
end