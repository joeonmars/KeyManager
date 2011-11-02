/*
	AS3 KeyManager class
	ver 0.01
	Coded by Joe(Yixiong Zhou)
	http://www.joeonmars.com/
*/

package com.joeonmars.keymanager
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	public class KeyManager
	{
		public static var keyMapping:Dictionary = new Dictionary();
		public static var pressedKeyNames:Array = [];
		public static var pressedKeyCodes:Array = [];
		public static var downKeyNames:Array = [];
		public static var downKeyCodes:Array = [];
		public static var upKeyNames:Array = [];
		public static var upKeyCodes:Array = [];
		public static var isEnabled:Boolean;
		
		private static var _lastKeyCode:int = -1;
		private static var _stage:*;
		
		public function KeyManager()
		{
			
		}
		
		public static function enable():void
		{
			isEnabled = true;
		}
		
		public static function disable():void
		{
			isEnabled = false;
		}
		
		public static function addKeyMappings( aArray:Array ):void
		{
			// params: [{name:a string,code:an integer},{}...]
			for each( var obj:Object in aArray )
			{
				keyMapping[obj.name] = obj.code;
			}
		}
		
		public static function removeKeyMappings( aArray:Array ):void
		{
			// params: [name1,name2,name3...]
			for each( var name:String in aArray )
			{
				delete keyMapping[name];
			}
		}
		
		public static function registerStage( aStage:Stage ):void
		{
			if( _stage ) removeListeners();
			
			_stage = aStage;
			
			_stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			_stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			_stage.addEventListener( Event.DEACTIVATE, onDeactivate );
			
			enable();
		}
		
		public static function removeListeners():void
		{
			if( _stage == null ) return;
			
			_stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			_stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			_stage.removeEventListener( Event.DEACTIVATE, onDeactivate );
		}
		
		public static function destroy():void
		{
			disable();
			removeListeners();
			
			keyMapping = new Dictionary();
			_stage = null;
			pressedKeyNames = [];
			pressedKeyCodes = [];
			downKeyNames = [];
			downKeyCodes = [];
			upKeyNames = [];
			upKeyCodes = [];
			_lastKeyCode = -1;
		}
		
		public static function simKeyDown( aKeyName:String ):void
		{
			if( !(keyMapping[aKeyName] is int) )
			{
				trace( 'KeyManager cannot find a registered key named ' + '"' + aKeyName + '"!' );
				return;
			}
			
			downKeyNames = [ aKeyName ];
			downKeyCodes = [ keyMapping[aKeyName] ];
		}
		
		public static function simKeyUp( aKeyName:String ):void
		{
			if( !(keyMapping[aKeyName] is int) )
			{
				trace( 'KeyManager cannot find a registered key named ' + '"' + aKeyName + '"!' );
				return;
			}
			
			upKeyNames = [ aKeyName ];
			upKeyCodes = [ keyMapping[aKeyName] ];
		}
		
		public static function simKeyPressed( aKeyNameParam:*, aClear:Boolean = true ):void
		{
			var keyNames:Array = [];
			if( aKeyNameParam is Array ) keyNames = aKeyNameParam;
			else if( aKeyNameParam is String ) keyNames.push( aKeyNameParam );
			
			for each( var keyName:String in keyNames )
			{
				if( !(keyMapping[keyName] is int) )
				{
					trace( 'KeyManager cannot find a registered key named ' + '"' + keyName + '"!' );
					continue;
				}
				
				pressedKeyNames.push( keyName );
				pressedKeyCodes.push( keyMapping[keyName] );	
			}
		}
		
		public static function getLastPressedKey( aArray:Array ):String
		{
			aArray.sort( sortOnIndex );
			return aArray[0];
		}
		
		private static function sortOnIndex(k1:String,k2:String):int
		{
			if( pressedKeyNames.indexOf(k1) > pressedKeyNames.indexOf(k2) ) return -1;
			else return 1;
		}
		
		public static function hasKey( aKey:*, aArray:Array ):Boolean
		{
			if( aArray.indexOf(aKey) == -1 ) return false;
			else return true;
		}
		
		public static function isKeyDown( aKey:* ):Boolean
		{
			if( aKey is String )
			{
				if( downKeyNames.indexOf(aKey) == -1 ) return false;
			}
			else if( aKey is int )
			{
				if( downKeyCodes.indexOf(aKey) == -1 ) return false;
			}
			
			return true;
		}
		
		public static function isKeyUp( aKey:* ):Boolean
		{
			if( aKey is String )
			{
				if( upKeyNames.indexOf(aKey) == -1 ) return false;
			}
			else if( aKey is int )
			{
				if( upKeyCodes.indexOf(aKey) == -1 ) return false;
			}
			
			return true;
		}
		
		public static function isKeyPressed( aKey:* ):Boolean
		{
			if( aKey is String )
			{
				if( pressedKeyNames.indexOf(aKey) == -1 ) return false;
			}
			else if( aKey is int )
			{
				if( pressedKeyCodes.indexOf(aKey) == -1 ) return false;
			}
			
			return true;
		}
		
		public static function updateAfterInput():void
		{
			downKeyNames = [];
			downKeyCodes = [];
			upKeyNames = [];
			upKeyCodes = [];
		}
		
		private static function onKeyDown( e:KeyboardEvent ):void
		{
			if( !isEnabled || _lastKeyCode == e.keyCode ) return;
			
			_lastKeyCode = e.keyCode;
			
			var code:int;
			
			for( var name:String in keyMapping )
			{
				code = keyMapping[name];
				
				if( code == e.keyCode )
				{
					if( pressedKeyCodes.indexOf(code) == -1 )
					{
						pressedKeyNames.push(name);
						pressedKeyCodes.push(code);
					}
					downKeyNames.push(name);
					downKeyCodes.push(code);
					break;
				}
			}
		}
		
		private static function onKeyUp( e:KeyboardEvent ):void
		{
			if( !isEnabled ) return;
			
			_lastKeyCode = -1;
			
			var code:int;
			
			for( var name:String in keyMapping )
			{
				code = keyMapping[name];
				
				if( code == e.keyCode )
				{
					pressedKeyNames.splice( pressedKeyNames.indexOf(name), 1 );
					pressedKeyCodes.splice( pressedKeyCodes.indexOf(code), 1 );
					upKeyNames.push( name );
					upKeyCodes.push( code );
					break;
				}
			}
		}
		
		private static function onDeactivate( e:Event ):void
		{
			pressedKeyNames = [];
			pressedKeyCodes = [];
			downKeyNames = [];
			downKeyCodes = [];
			upKeyNames = [];
			upKeyCodes = [];
			_lastKeyCode = -1;
		}
		
		/* --------------------------- end ----------------------------- */
	}
}