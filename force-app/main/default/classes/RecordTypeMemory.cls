/*******************************************************************************
*                     Copyright (C) 2013 - Cloud2b
*-------------------------------------------------------------------------------
*
* Recupera a identificação de um tipo de registro
* NAME: RecordTypeMemory.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 14/01/2013
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR:                                           DATE:
* DESC:
*******************************************************************************/

public with sharing class RecordTypeMemory {

  private static Map< String, Map< String, Id > > fRecTypes = new Map< String, Map< String, Id > >();
  private static Map< String, String > recTypeNames = new Map< String, String >();
  
  static {
    List< RecordType > lList = [ select id, SobjectType, Name, DeveloperName from RecordType ];
    for ( RecordType lRec : lList )
    {
      Map< String, Id > lObjMap = fRecTypes.get( lRec.SobjectType );
      if ( lObjMap == null )
      {
        lObjMap = new Map< String, Id >();
        fRecTypes.put( lRec.SobjectType, lObjMap );
      }
      lObjMap.put( lRec.DeveloperName, lRec.id );
      recTypeNames.put(lRec.DeveloperNAme, lRec.Name);
    }
  }
  
  public static Id getRecType( String aObj, String aDevName )
  {
    Map< String, Id > lObjMap = fRecTypes.get( aObj );
    if ( lObjMap == null ) return null;
    return lObjMap.get( aDevName );
  }
    
  public static Map< String, Id > getRecTypes( String aObj  )
  {
    return fRecTypes.get( aObj );
  }

  public static String getNameByDevName( String devName )
  {
    return recTypeNames.get( devName );
  }     
  
}