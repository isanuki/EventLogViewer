public with sharing class EventLogCsvController {

	public List<List<String>> csvFiles {get; set;}
	public String getFileName(){
		return String.valueOf(System.now().format('yyyyMMdd_HHmm'));
	}

	public EventLogCsvController(){
		String eventTypeParam = ApexPages.currentPage().getParameters().get('et');
		String startParam = ApexPages.currentPage().getParameters().get('st');
		String endParam   = ApexPages.currentPage().getParameters().get('ed');
		system.debug('@@@ et='+ eventTypeParam +':st='+ startParam + ';ed='+endParam);
		
		Date strtDate = String.isNotBlank(startParam) ? Date.valueOf(startParam) : null;
		Date endDate  = String.isNotBlank(endParam)   ? Date.valueOf(endParam) : null;
		
		for(EventLogFile elf : [SELECT Id, LogDate, LogFile FROM EventLogFile 
		                         WHERE LogDate >=: strtDate
		                           AND LogDate <=: endDate
		                           AND EventType =: eventTypeParam
		                           ORDER BY LogDate DESC]){
			if(csvFiles == null){
				csvFiles = EventLogUtil.parseCSV(elf.LogFile.toString(), false, true);
			} else {
				// 2ファイル目以降
				csvFiles.addAll(EventLogUtil.parseCSV(elf.LogFile.toString(), true, true));
			}
		}
		system.debug(csvFiles.size());
	}

}