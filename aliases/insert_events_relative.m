% alias due to change in function naming scheme

function EEG = insert_events_relative(EEG, anchor, relpos, newmarker)

   EEG = events_insert_relative(EEG, newmarker, anchor, relpos);
   
end