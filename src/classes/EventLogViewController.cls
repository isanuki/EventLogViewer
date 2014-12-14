public with sharing class EventLogViewController {

	static final String CLAC_TYPE_COUNT = 'count';
	static final String CLAC_TYPE_AVG = 'avg';

	static final Integer ROUND_UP_NUM = 2;
	static final Integer CSV_NUM_VF_PAGENAME = 9;
	static final Integer CSV_NUM_VF_RUNTIME = 5;
	static final Integer CSV_NUM_REPO_NAME = 12;
	static final Integer CSV_NUM_API_METHOD = 12;
	static final Integer CSV_NUM_VF_VIEWSTATE = 17;
	static final Integer CSV_NUM_UN_USED = 0;

	static public final String ANL_VF_RUNTIME = '01';
	static public final String ANL_VF_PAGEUSE = '02';
	static public final String ANL_REPORT_USE = '03';
	static public final String ANL_VF_VIEWSTATE = '04';
	static public final String ANL_API_METHOD = '05';
	public List<SelectOption> getAnalysisTypeList(){
		List<SelectOption> ret = new List<SelectOption>();
		ret.add(new SelectOption('none', System.Label.ELV_UnSelected));
		ret.add(new SelectOption(ANL_VF_RUNTIME, System.Label.ELV_AnlSelect01));
		ret.add(new SelectOption(ANL_VF_VIEWSTATE, System.Label.ELV_AnlSelect04));
		ret.add(new SelectOption(ANL_VF_PAGEUSE, System.Label.ELV_AnlSelect02));
		ret.add(new SelectOption(ANL_API_METHOD, System.Label.ELV_AnlSelect05));
		ret.add(new SelectOption(ANL_REPORT_USE, System.Label.ELV_AnlSelect03));
		return ret;
	}
	public List<SelectOption> eventTypeList {get; set;}
	public String selectedEventType {get; set;}
	public String selectedAnalysisType {get; set;}
	public String selectedMode {get; set;}
	public Task tsk {get; set;}
	public List<List<String>> csvFiles {get; set;}
	public List<String> csvFileHeader {get; set;}
	public List<EventLogAnlWrap> anlDatas {get; set;}
	public String anlXtitle {get; set;}
	public String anlYtitle {get; set;}
	public String anltitle {get; set;}
	public String startDateParam {get; set;}
	public String endDateParam {get; set;}
	
	public EventLogViewController(){
		selectedMode = 'list';
		tsk = new Task(RecurrenceStartDateOnly=null, RecurrenceEndDateOnly=null);
	}

	public void init(){
		eventTypeList = new List<SelectOption>();
		eventTypeList.add(new SelectOption('none', System.Label.ELV_UnSelected));
		for(AggregateResult ar : [SELECT COUNT(Id), EventType FROM EventLogFile GROUP BY EventType]){
			String eventType = String.valueOf(ar.get('EventType'));
			eventTypeList.add(new SelectOption(eventType, eventType));
		}
		
	}

	public PageReference serachLog(){
		system.debug('@@@検索条件：type='+ selectedEventType + '@start='+tsk.RecurrenceStartDateOnly + '@end='+tsk.RecurrenceEndDateOnly );
		
		csvFileHeader = null;
		csvFiles = null;
		anlDatas = null;
		String soql = 'SELECT Id, LogDate, LogFile FROM EventLogFile ';
		soql += 'WHERE LogDate >=: startDate AND LogDate <=: endDate ';
		
		if(selectedMode == 'list'){
			// 入力値チェック
			if(selectedMode == 'list' && selectedEventType == 'none' ){
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.ELV_Warning01));
				return null;
			}
			
			// クエリ生成
			soql += 'AND EventType =:selectedEventType ';
			soql += 'ORDER BY LogDate DESC';			
			
			// クエリ投げる
			csvFiles = convertEvlRecToCsv(soql);
			
			// ヘッダー行だけ分ける
			if(csvFiles == null || csvFiles.size() <= 1){
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.ELV_Warning03));
			} else {
				csvFileHeader = csvFiles.remove(0);
				startDateParam = tsk.RecurrenceStartDateOnly != null ? String.valueOf(tsk.RecurrenceStartDateOnly) : null;
				endDateParam   = tsk.RecurrenceendDateOnly != null ? String.valueOf(tsk.RecurrenceEndDateOnly) : null;
			}
		} else if(selectedMode == 'analysis'){
			// 入力値チェック
			if(selectedMode == 'analysis' && selectedAnalysisType == 'none'){
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.ELV_Warning02));
				return null;
			}
			
			// クエリ生成
			soql += 'AND EventType = ' + getAnlEventType(selectedAnalysisType);
			
			// クエリ投げる
			List<List<String>> csv = convertEvlRecToCsv(soql);
			if(csv != null && csv.size() > 0){
				Map<String, EventLogAnlWrap> elawMap = new Map<String, EventLogAnlWrap>();
				if(selectedAnalysisType == ANL_VF_RUNTIME){
					elawMap = aggrCsvToAnalysisWrap(csv, CSV_NUM_VF_PAGENAME, CSV_NUM_VF_RUNTIME, CLAC_TYPE_AVG);
					anlXtitle = System.Label.ELV_AnlAxis01;
					anlYtitle = System.Label.ELV_AnlAxis02;
				} else if(selectedAnalysisType == ANL_VF_PAGEUSE){
					elawMap = aggrCsvToAnalysisWrap(csv, CSV_NUM_VF_PAGENAME, CSV_NUM_UN_USED, CLAC_TYPE_COUNT);
					anlXtitle = System.Label.ELV_AnlAxis01;
					anlYtitle = System.Label.ELV_AnlAxis03;
				} else if(selectedAnalysisType == ANL_REPORT_USE){
					elawMap = aggrCsvToAnalysisWrap(csv, CSV_NUM_REPO_NAME, CSV_NUM_UN_USED, CLAC_TYPE_COUNT);
					anlXtitle = System.Label.ELV_AnlAxis04;
					anlYtitle = System.Label.ELV_AnlAxis03;
					
					// Id値からNameに変換
					for(Report repo : [SELECT Id,Name FROM Report WHERE Id in: elawMap.keySet()]){
						EventLogAnlWrap obj = elawMap.get(String.valueOf(repo.Id).left(15)); //csv側はID15桁
						obj.name = repo.Name;
						elawMap.put(repo.Id, obj);
					}
				} else if(selectedAnalysisType == ANL_VF_VIEWSTATE){
					elawMap = aggrCsvToAnalysisWrap(csv, CSV_NUM_VF_PAGENAME, CSV_NUM_VF_VIEWSTATE, CLAC_TYPE_AVG);
					anlXtitle = System.Label.ELV_AnlAxis01;
					anlYtitle = System.Label.ELV_AnlAxis05;
				} else if(selectedAnalysisType == ANL_API_METHOD){
					elawMap = aggrCsvToAnalysisWrap(csv, CSV_NUM_API_METHOD, CSV_NUM_UN_USED, CLAC_TYPE_COUNT);
					anlXtitle = System.Label.ELV_AnlAxis07;
					anlYtitle = System.Label.ELV_AnlAxis06;
				}
				anlDatas = elawMap.values();
				anlDatas.sort();
				
			}
			if(anlDatas == null || anlDatas.size() == 0){
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.ELV_Warning03));
			}
			system.debug('@@@'+anlDatas);
		}
		
		return null;
	}

	private List<List<String>> convertEvlRecToCsv(String soql){
		System.debug('@@@soql='+soql);
		List<List<String>> retCsv = null;
		Date startDate = tsk.RecurrenceStartDateOnly;
		Date endDate   = tsk.RecurrenceEndDateOnly;
		for(EventLogFile elf : Database.query(soql)){
			if(retCsv == null){
				retCsv = EventLogUtil.parseCSV(elf.LogFile.toString(), false, false);
			} else {
				// 2ファイル目以降
				retCsv.addAll(EventLogUtil.parseCSV(elf.LogFile.toString(), true, false));
			}
		}
		return retCsv;
	}
	
	private String getAnlEventType(String anlType){
		String retWhereField;
		if(anlType == ANL_VF_RUNTIME){
			retWhereField = '\'VisualforceRequest\' ';
		} else if(anlType == ANL_VF_PAGEUSE){
			retWhereField = '\'VisualforceRequest\' ';
		} else if(anlType == ANL_REPORT_USE){
			retWhereField = '\'Report\' ';
		} else if(anlType == ANL_VF_VIEWSTATE){
			retWhereField = '\'VisualforceRequest\' ';
		} else if(anlType == ANL_API_METHOD){
			retWhereField = '\'API\' ';
		}
		return retWhereField;
	}
	

	/**
	 * csvを読んで分析用ラッパーに集計する
	 */
	private Map<String, EventLogAnlWrap> aggrCsvToAnalysisWrap(List<List<String>> csv,
	                                                           Integer summaryClmNum,
	                                                           Integer calcClmNum, String CalcType){
		
		// ヘッダー行から項目名を取得
		List<String> header =csv.remove(0);
		
		system.debug('@@@analysis csvRowSize=' +csv.size());
		Map<String, EventLogAnlWrap> elawMap = new Map<String, EventLogAnlWrap>();

		// 種類別の出現数
		if(calcType == CLAC_TYPE_COUNT){
			for(List<String> record : csv){
				String summaryClmName = record.get(summaryClmNum);
				if(isExclusionName(summaryClmName)) continue;
				EventLogAnlWrap tmpObj = elawMap.get(summaryClmName);
				if(tmpObj == null){
					elawMap.put(summaryClmName, new EventLogAnlWrap(summaryClmName, Double.valueOf(1.0))); //1.0は初期値
				} else {
					tmpObj.val++;
					elawMap.put(summaryClmName, tmpObj);
				}
			}
		// 種類別の平均値
		} else if(calcType == CLAC_TYPE_AVG){
			Map<String, Integer> countMap = new Map<String, Integer>();
			for(List<String> record : csv){
				String summaryClmName = record.get(summaryClmNum);
				if(isExclusionName(summaryClmName)) continue;
				EventLogAnlWrap tmpObj = elawMap.get(summaryClmName);
				if(tmpObj == null){
					elawMap.put(summaryClmName, new EventLogAnlWrap(summaryClmName, Double.valueOf(1.0))); //1.0は初期値
					countMap.put(summaryClmName, 1);
				} else {
					tmpObj.val += Double.valueOf(record.get(calcClmNum));
					elawMap.put(summaryClmName, tmpObj);
					countMap.put(summaryClmName, (countMap.get(summaryClmName) + 1));
				}
			}
			
			for(EventLogAnlWrap elaw : elawMap.values()){
				Integer cnt = countMap.get(elaw.name);
				Decimal d = elaw.val / cnt;
				elaw.val = d.setScale(ROUND_UP_NUM, System.RoundingMode.HALF_UP);
				elawMap.put(elaw.name, elaw);
			}
			
		}
		
		//List<EventLogAnlWrap> ls = elawMap.values();
		//ls.sort();
		return elawMap;
	}

	private Boolean isExclusionName(String str){
		return (String.isBlank(str) || str == '"');
	}

/*
	// CSVParseのCodeSampleをカスタマイズして利用
	// https://developer.salesforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
	private List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
		List<List<String>> allFields = new List<List<String>>();
	
		// replace instances where a double quote begins a field containing a comma
		// in this case you get a double quote followed by a doubled double quote
		// do this for beginning and end of a field
		contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
		// now replace all remaining double quotes - we do this so that we can reconstruct
		// fields with commas inside assuming they begin and end with a double quote
		contents = contents.replaceAll('""','DBLQT');
		// we are not attempting to handle fields with a newline inside of them
		// so, split on newline to get the spreadsheet rows
		List<String> lines = new List<String>();
		try {
			lines = contents.split('\n');
		} catch (System.ListException e) {
			System.debug('Limits exceeded?' + e.getMessage());
		}
		Integer num = 0;
		for(String line : lines) {
			// check for blank CSV lines (only commas)
			if (line.replaceAll(',','').trim().length() == 0) break;
			
			List<String> fields = line.split(',');	
			List<String> cleanFields = new List<String>();
			String compositeField;
			Boolean makeCompositeField = false;
			for(String field : fields) {
				if (field.startsWith('"') && field.endsWith('"')) {
					//cleanFields.add(field.replaceAll('DBLQT','"'));
					String tmp = field.replaceAll('DBLQT','"');
					cleanFields.add( tmp.substring(1, tmp.length()-1) );
				} else if (field.startsWith('"')) {
					makeCompositeField = true;
					compositeField = field;
				} else if (field.endsWith('"')) {
					compositeField += ',' + field;
					cleanFields.add(compositeField.replaceAll('DBLQT','"'));
					makeCompositeField = false;
				} else if (makeCompositeField) {
					compositeField +=  ',' + field;
				} else {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				}
			}
			
			allFields.add(cleanFields);
		}
		if (skipHeaders) allFields.remove(0);
		return allFields;		
	}
*/
}