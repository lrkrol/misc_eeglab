% alias due to change in function naming scheme

function varargout = replay_events(varargin)

   [varargout{1:nargout}] = events_replay(varargin{:});
   
end