@isTest
private class ZTSyncOrder {
	
	@isTest static void test_method_one() {

		SyncOrderCtrl ctrl = new SyncOrderCtrl();
		ctrl.orderCode = '12034';
		ctrl.findOrder();

	}
	
}