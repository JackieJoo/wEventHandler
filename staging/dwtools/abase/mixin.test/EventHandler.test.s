( function _EventHandler_test_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  //if( typeof wBase === 'undefined' )
  try
  {
    require( '../../Base.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  _.include( 'wTesting' );
  require( '../mixin/EventHandler.s' );

}

var _ = wTools;

// --
// test
// --

function basic( test )
{
  var self = this;

  var samples =
  [
  ];

  //

  function Entity1(){};
  wEventHandler.mixin( Entity1 );
  var entity1 = new Entity1();

  function Entity2(){};
  wEventHandler.mixin( Entity2 );
  var entity2 = new Entity2();

  //

  test.description = 'eventHandlerAppend';

  function onEvent1( e ){ return entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; };
  function onEvent2( e ){ return entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; };
  function onEvent3( e ){ return entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; };

  debugger;

  entity1.on( 'event1',onEvent1 );
  entity1.eventHandlerAppend( 'event2',onEvent2 );
  entity1.on( 'event3','owner',onEvent3 );

  test.identical( entity1._eventHandlerDescriptorByHandler( onEvent1 ).onHandle,onEvent1 );
  test.identical( entity1._eventHandlerDescriptorByHandler( onEvent3 ).owner,'owner' );
  test.identical( entity1._eventHandlerDescriptorByKindAndOwner( 'event3','owner' ).onHandle,onEvent3 );
  test.identical( entity1._eventHandlerDescriptorByKindAndOwner( 'event3','owner' ).kind,'event3' );
  test.identical( entity1._eventHandlerDescriptorByKindAndOwner( 'event3','owner' ).owner,'owner' );
  test.identical( entity1._eventHandlerDescriptorByKindAndHandler( 'event3',onEvent3 ).owner,'owner' );

  //

  test.identical( entity1.eventGive( 'event1' ),[ 1 ] );
  test.identical( entity1[ 'event1' ], 1 );

  test.identical( entity1.eventGive( 'event2' ),[ 1 ] );
  test.identical( entity1.eventGive( 'event2' ),[ 2 ] );
  test.identical( entity1[ 'event2' ], 2 );

  test.identical( entity1.eventGive( 'event3' ),[ 1 ] );
  test.identical( entity1.eventGive( 'event3' ),[ 2 ] );
  test.identical( entity1[ 'event3' ], 2 );

  //

  test.description = 'eventHandleUntil';

  function onUntil0( e ){ entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; return 0; };
  function onUntil1( e ){ entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; return 1; };
  function onUntil2( e ){ entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; return 2; };
  function onUntil3( e ){ entity1[ e.kind ] = ( entity1[ e.kind ] || 0 ) + 1; return 3; };

  entity1.on( 'until',onUntil0 );
  entity1.on( 'until',onUntil1 );
  entity1.on( 'until',onUntil2 );
  entity1.on( 'until','onUntil3_owner',onUntil3 );

  test.identical( entity1.eventHandleUntil( 'until',0 ),0 );
  test.identical( entity1[ 'until' ], 1 );

  test.identical( entity1.eventHandleUntil( 'until',1 ),1 );
  test.identical( entity1[ 'until' ], 3 );

  test.identical( entity1.eventHandleUntil( 'until',2 ),2 );
  test.identical( entity1[ 'until' ], 6 );

  //

  test.description = 'eventHandlerRemove';

  entity1.eventHandlerRemove( 'until',onUntil0 );
  test.identical( entity1.eventHandleUntil( 'until',0 ),undefined );
  test.identical( entity1[ 'until' ], 9 );

  entity1.eventHandlerRemove( onUntil1 );
  test.identical( entity1.eventHandleUntil( 'until',1 ),undefined );
  test.identical( entity1[ 'until' ], 11 );

  entity1.eventHandlerRemove( 'until' );
  test.identical( entity1.eventHandleUntil( 'until',1 ),undefined );
  test.identical( entity1[ 'until' ], 11 );

  test.identical( entity1.eventGive( 'event3' ),[ 3 ] );
  test.identical( entity1[ 'event3' ], 3 );
  entity1._eventHandlerRemove({ owner : 'owner' });
  test.identical( entity1.eventHandleUntil( 'until',1 ),undefined );
  test.identical( entity1.eventGive( 'event3' ),[] );
  test.identical( entity1[ 'event3' ], 3 );

  test.identical( entity1.eventGive( 'event1' ),[ 2 ] );
  test.identical( entity1[ 'event1' ], 2 );

  //

  test.description = 'eventProxyTo';

  var entity1 = {};
  wEventHandler.mixin( entity1 );

  var entity2 = {};
  wEventHandler.mixin( entity2 );

  entity1.on( 'event1','owner',onEvent1 );
  entity1.on( 'event1','owner',onEvent1 );
  entity1.on( 'event1','owner',onEvent1 );
  entity1.on( 'event1','owner',onEvent1 );
  entity1.on( 'event1','owner',onEvent1 );
  entity1.on( 'event1','owner',onEvent2 );
  entity1.on( 'event1','owner3',onEvent3 );

  entity1.on( 'event33',onEvent3 );
  entity1.on( 'event33',onEvent3 );
  entity1.eventProxyFrom( entity2,
  {
    'event1' : 'event1',
    'event3' : 'event33',
  });

  test.identical( entity1.eventGive( 'event1' ),[ 1,2 ] );
  test.identical( entity1.eventGive( 'event2' ),[] );
  test.identical( entity1.eventGive( 'event3' ),[] );
  test.identical( entity1.eventGive( 'event33' ),[ 1,2 ] );

  test.identical( entity2.eventGive( 'event1' ),[ 3,4 ] );
  test.identical( entity2.eventGive( 'event2' ),[] );
  test.identical( entity2.eventGive( 'event3' ),[ 3,4 ] );
  test.identical( entity2.eventGive( 'event33' ),[] );

  test.identical( entity1[ 'event1' ], 4 );
  test.identical( entity1[ 'event2' ], undefined );
  test.identical( entity1[ 'event3' ], undefined );
  test.identical( entity1[ 'event33' ], 4 );

  //

  test.description = 'eventHandlerRemoveByKindAndOwner';

  test.identical( entity1.eventGive( 'event1' ),[ 5,6 ] );
  test.identical( entity1[ 'event1' ], 6 );
  try
  {
    entity1.eventHandlerRemove( onEvent1 );
    test.identical( 'error had to be throwen because no such handler',false );
  }
  catch( err )
  {
    test.identical( 1,1 );
  }

  test.identical( entity1.eventGive( 'event1' ),[ 7,8 ] );
  test.identical( entity1[ 'event1' ], 8 );
  entity1.eventHandlerRemoveByKindAndOwner( 'event1','owner' );
  test.identical( entity1.eventGive( 'event1' ),[ 9 ] );
  test.identical( entity1[ 'event1' ], 9 );

  test.identical( entity1.eventGive( 'event33' ),[ 5,6 ] );
  test.identical( entity1[ 'event33' ], 6 );
  entity1.eventHandlerRemove();
  test.identical( entity1.eventGive( 'event33' ),[] );
  test.identical( entity1[ 'event33' ], 6 );
  test.identical( entity1.eventGive( 'event1' ),[] );
  test.identical( entity1[ 'event1' ], 9 );

  //

  test.description = 'once';

  entity1.once( 'event2',onEvent2 );
  test.identical( entity1.eventGive( 'event2' ),[ 1 ] );
  test.identical( entity1.eventGive( 'event2' ),[] );
  test.identical( entity1[ 'event2' ], 1 );

  entity1.once( 'event2',onEvent2 );
  entity1.once( 'event2',onEvent2 );
  entity1.once( 'event2',onEvent3 );
  test.identical( entity1.eventGive( 'event2' ),[ 2,3 ] );
  test.identical( entity1.eventGive( 'event2' ),[] );
  test.identical( entity1[ 'event2' ], 3 );

}

// --
// proto
// --

var Self =
{

  name : 'EventHandler',
  silencing : 1,

  tests :
  {

    basic : basic,

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
