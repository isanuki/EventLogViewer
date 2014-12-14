public class EventLogUtil {

	// CSVParseのCodeSampleをカスタマイズして利用
	// https://developer.salesforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
	public static List<List<String>> parseCSV(String contents,Boolean skipHeaders, Boolean isCsv) {
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
					if(isCsv){
						cleanFields.add(field.replaceAll('DBLQT','"'));
					} else {
						String tmp = field.replaceAll('DBLQT','"');
						cleanFields.add( tmp.substring(1, tmp.length()-1) );
					}
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
			if(isCsv) cleanFields.add('\n');
			allFields.add(cleanFields);
		}
		if (skipHeaders) allFields.remove(0);
		return allFields;		
	}

}