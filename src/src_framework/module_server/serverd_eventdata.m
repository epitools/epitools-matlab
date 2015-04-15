classdef (ConstructOnLoad) serverd_eventdata < event.EventData
   properties
      MessageUID = '';
   end
   methods
      function eventData = serverd_eventdata(value)
          eventData.MessageUID = value;
      end
   end
end