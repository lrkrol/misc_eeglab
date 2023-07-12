% alias due to change in function naming scheme

function varargout = photo2event(varargin)

   [varargout{1:nargout}] = events_insert_fromphotodiode(varargin{:});
   
end