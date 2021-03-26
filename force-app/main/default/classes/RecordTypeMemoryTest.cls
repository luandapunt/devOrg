/*******************************************************************************
*                               Cloud2b - 2014
*-------------------------------------------------------------------------------
* Classe que faz o teste de cobertura de teste da classe RecordTypeMemory
* NAME: RecordTypeMemoryTest.cls
* AUTHOR: LRSA                                                 DATE: 17/01/2013
*
*******************************************************************************/
@isTest
private class RecordTypeMemoryTest {

    static testMethod void myUnitTest() {
        RecordTypeMemory.getRecType( 'Case', 'Test' );
        RecordTypeMemory.getRecTypes( 'Case' );
        RecordTypeMemory.getNameByDevName( 'Case');
    }
}