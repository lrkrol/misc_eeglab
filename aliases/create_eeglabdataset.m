% alias due to change in function naming scheme

function varargout = create_eeglabdataset(varargin)

   [varargout{1:nargout}] = eeglabdataset_create(varargin{:});
   
end