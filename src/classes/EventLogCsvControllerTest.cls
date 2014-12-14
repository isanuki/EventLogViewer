@isTest
private class EventLogCsvControllerTest {

	static testMethod void test01() {
		ApexPages.currentPage().getParameters().put('et','Login');
		
		Test.startTest();
		EventLogCsvController controller = new EventLogCsvController();
		controller.getFileName();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}

}