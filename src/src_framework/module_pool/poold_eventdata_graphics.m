classdef (ConstructOnLoad) poold_eventdata_graphics < event.EventData
   properties
      TagArray = '';
   end
   methods
      function eventData = poold_eventdata_graphics(value)
          eventData.TagArray = value;
      end
   end
end