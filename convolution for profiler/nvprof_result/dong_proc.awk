BEGIN {
    metric_flag = 0;
    event_flag = 0;
} 
{
    where_event = index($0, "Event Name");
    if (where_event)
    {
       #print "Event results start!";
       event_flag = 1;
    }
    where_metric = index($0, "Metric Name");
    if (where_metric)
    {
       #print "Metric results start!";
       event_flag = 0;
       metric_flag = 1;
    }

    if(event_flag)
    {
       if(index($0, "17"))
          combined_event = combined_event "  " $NF;	 
    }
 
    if(metric_flag)
    {
       if(index($0, "17"))
          combined_metric = combined_metric "  " $NF
    }
}
END {
    print combined_event;
    print "\n";
    print "\n";
    print "\n";
    print combined_metric;
}

