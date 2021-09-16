classdef (ConstructOnLoad) poold_eventdata < event.EventData
   properties
      ModuleName = '';
   end
   methods
      function eventData = poold_eventdata(value)
          eventData.ModuleName = value;
      end
   end
end