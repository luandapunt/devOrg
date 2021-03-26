@isTest
public class ZTParentAccountSaleFormula {
    public static testmethod void runTest(){
        ParentAccountSaleFormula f = new ParentAccountSaleFormula();
        f.resolve(null, new Map<String, Object>{
            'KUNNR' => 1,
            'KUNN2' => 2
        });
    }
}