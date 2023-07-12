% alias due to change in function naming scheme

function varargout = get_iclabel_components(varargin)

   [varargout{1:nargout}] = iclabel_get_components(varargin{:});
   
end