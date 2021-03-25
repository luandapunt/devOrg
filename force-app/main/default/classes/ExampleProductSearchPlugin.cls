global class ExampleProductSearchPlugin implements SBQQ.ProductSearchPlugin{
global ExampleProductSearchPlugin()
    {
         System.debug('ProductSearchPlugin used ( constructor )');
    }

    global Boolean isFilterHidden( sObject quote, String fieldName )
    {
        //SBQQ__Quote__c al = (SBQQ__Quote__c) quote;
        //return fieldName == 'ProductCode' && al.SBQQ__Status__c == 'Approved';
        return false;
    }

    global String getFilterDefaultValue( sObject quote, String fieldName )
    {
        /*System.debug('METHOD: getFilterDefoultValue');
        SBQQ__Quote__c al = (SBQQ__Quote__c) quote;

        return ( fieldName == 'Family' && al.SBQQ__Type__c == 'Quote' ) ? 'Service' : ''; */
        return NULL;
    }

    global Boolean isSearchCustom( sObject quote, Map<String,Object> fieldValuesMap )
    {
        /*
        System.debug('METHOD: isSearchCustom');

        return fieldValuesMap.get('Sort_By__c') != '';
		*/
        
        return false;
    }

    global Boolean isSuggestCustom( sObject quote, Map<String,Object> fieldValuesMap )
    {
        return false;
    }

    global Boolean isInputHidden( sObject quote, String Field )
    {
        return false;
    }

    global Object getInputDefaultValue( sObject query, String value )
    {
        return NULL;
    }

    global String getAdditionalSuggestFilters( sObject query, Map<String,Object> suggFilts )
    {
        return NULL;
    }

    global List<PricebookEntry> suggest( sObject query, Map<String,Object> usg )
    {
        return NULL;
    }

    global String getAdditionalSearchFilters( sObject quote, Map<String,Object> fieldValuesMap )
    {
        /*
        System.debug('METHOD: getAdditionalSearchFilters');

        String additionalFilter = NULL;
        if(fieldValuesMap.get('Family') == 'Hardware')
        {
            additionalFilter = 'AND Product2.Inventory_Level__c > 3';
        }

        return additionalFilter;
		*/
        /*
        SBQQ__Quote__c qt = (SBQQ__Quote__c) quote;
        String additionalFilter = NULL;
        if(fieldValuesMap.get('Business_Unit__c') == qt.Business_Unit__c){
            additionalFilter = 'AND Product2.Business_Unit__c = ' + qt.Business_Unit__c;
        }
        
        return additionalFilter; */
        return NULL;
    }

    global List<PricebookEntry> search(SObject quote, Map<String,Object> fieldValuesMap)
    {
        /*
        System.debug('METHOD CALLED: search');
        //GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
        List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchFilters.getFields();

        //GET ALL POSSIBLE FIELDS FROM THE SEARCH RESULTS FIELD SET
        List<Schema.FieldSetMember> searchResultFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchResults.getFields();

        //BUILD THE SELECT STRING
        String selectClause = 'SELECT ';

        for(Schema.FieldSetMember field : searchResultFieldSetFields){
            selectClause += 'Product2.' + field.getFieldPath() + ', ';
        }
        selectClause += 'Id, UnitPrice, Pricebook2Id, Product2Id, Product2.Id';

        //BUILD THE WHERE CLAUSE
        String whereClause = '';

        for(Schema.FieldSetMember field : searchFilterFieldSetFields){
            if(!fieldValuesMap.containsKey(field.getFieldPath())){
                continue;
            }

            if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
                whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + fieldValuesMap.get(field.getFieldPath()) + '%\' AND ';
            }
        }

        whereClause += 'Pricebook2Id = \'' + quote.get('SBQQ__Pricebook__c') + '\'';

        //BUILD THE QUERY
        String query = selectClause + ' FROM PricebookEntry WHERE ' + whereClause;

        //DO THE QUERY
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        pbes = Database.query(query);

        return pbes;
*/
        return NULL;
        
    }
}