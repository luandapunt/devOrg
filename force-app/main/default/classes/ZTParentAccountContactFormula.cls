@isTest
public class ZTParentAccountContactFormula {
    public static testmethod void runTest(){
        ParentAccountContactFormula f = new ParentAccountContactFormula();
        f.resolve(null, new Map<String, Object>{
            'KUNNR' => 1,
            'PARNR' => 2
        });
    }
}