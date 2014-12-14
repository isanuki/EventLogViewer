@isTest
private class EventLogViewControllerTest {

	static testMethod void test_list01() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'list';
		controller.selectedEventType = 'api';
		
		Test.startTest();
		controller.init();
		controller.serachLog();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}

	static testMethod void test_analysis01() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'analysis';
		controller.selectedAnalysisType = EventLogViewController.ANL_VF_RUNTIME;
		
		Test.startTest();
		controller.init();
		controller.serachLog();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}

	static testMethod void test_analysis02() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'analysis';
		controller.selectedAnalysisType = EventLogViewController.ANL_VF_PAGEUSE;
		
		Test.startTest();
		controller.init();
		controller.serachLog();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}

	static testMethod void test_analysis03() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'analysis';
		controller.selectedAnalysisType = EventLogViewController.ANL_REPORT_USE;
		
		Test.startTest();
		controller.init();
		controller.serachLog();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}
	
	static testMethod void test_analysis04() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'analysis';
		controller.selectedAnalysisType = EventLogViewController.ANL_VF_VIEWSTATE;
		
		Test.startTest();
		controller.init();
		controller.serachLog();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}
	
	static testMethod void test_analysis05() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'analysis';
		controller.selectedAnalysisType = EventLogViewController.ANL_API_METHOD;
		
		Test.startTest();
		controller.init();
		controller.serachLog();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}
	
	static testMethod void test_other() {
		EventLogViewController controller = new EventLogViewController();
		controller.selectedMode = 'list';
		
		Test.startTest();
		controller.getAnalysisTypeList();
		Test.stopTest();
		
		// ログは組織依存するのでassertは入れてない
	}
}