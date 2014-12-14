global class EventLogAnlWrap implements Comparable{

	public String name{get; set;}
	public Double val{get; set;}

	public EventLogAnlWrap(String n, Double v){
		name = n;
		val  = v;
	}

	global Integer compareTo(Object compareTo){
		EventLogAnlWrap compareToElv = (EventLogAnlWrap) compareTo;
		Integer ret = 1;
		if(val == compareToElv.val){
			ret = 0;
		} else if(val > compareToElv.val){
			ret = -1;
		}
		return ret;
	}

}