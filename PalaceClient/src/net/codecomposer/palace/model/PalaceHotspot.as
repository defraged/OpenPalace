/*
This file is part of OpenPalace.

OpenPalace is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OpenPalace is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenPalace.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.codecomposer.palace.model
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class PalaceHotspot
	{
		
		public var type:int = 0;
		public var dest:int = 0;
		public var id:int = 0;
		public var flags:int = 0;
		public var state:int = 0;
		public var numStates:int = 0;
		public var polygon:Array = []; // Array of points
		public var name:String = null;
		public var location:Point;
		public var scriptEventMask:int = 0;
		public var numScripts:int = 0;
		public var secureInfo:int;
		public var refCon:int;
		public var groupId:int;
		public var scriptRecordOffset:int;
		
		public static const TYPE_NORMAL:int = 0;
		public static const TYPE_DOOR:int = 1;
		public static const TYPE_SHUTABLE_DOOR:int = 2;
		public static const TYPE_LOCKABLE_DOOR:int = 3;
		public static const TYPE_BOLT:int = 4;
		public static const TYPE_NAVAREA:int = 5;
		
		public static const STATE_UNLOCKED:int = 0;
		public static const STATE_LOCKED:int = 1;
		
		public function PalaceHotspot()
		{
		}

		public function readData(endian:String, bs:Array, offset:int):void {
			trace("Hotspot offset " + offset);
			location = new Point();
			
			// FIXME:  This seems broken.  The name is not read reliably
			// and the coordinates for the polygon are not at all correct
			// most of the time, but are correct sometimes.  No idea.
			
			var ba:ByteArray = new ByteArray();
			for (var j:int=offset; j < offset+size+1; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			scriptEventMask = ba.readInt();
			flags = ba.readInt();
			secureInfo = ba.readInt();
			refCon = ba.readInt();
			location.y = ba.readShort();
			location.x = ba.readShort();
			trace("Location X: " + location.x + " - Location Y: " + location.y);
			id = ba.readShort();
			dest = ba.readShort();
			var numPoints:int = ba.readShort();
			trace("Number points: " + numPoints);
			var pointsOffset:int = ba.readShort();
			trace("Points offset: " + pointsOffset);
			type = ba.readShort();
			groupId = ba.readShort();
			numScripts = ba.readShort();
			scriptRecordOffset = ba.readShort();
			state = ba.readShort();
			numStates = ba.readShort();
			var stateRecordOffset:int = ba.readShort();
			var nameOffset:int = ba.readShort();
			var scriptTextOffset:int = ba.readShort();
			ba.readShort();
			if (nameOffset > 0) {
				var nameByteArray:ByteArray = new ByteArray();
				var nameLength:int = bs[nameOffset];
				for (var a:int = nameOffset+1; a < nameOffset+nameLength+1; a++) {
					nameByteArray.writeByte(bs[a]);
				}
				nameByteArray.position = 0;
				name = nameByteArray.readMultiByte(nameLength, 'iso-8859-1');
			}

			ba = new ByteArray();
			var endPos:int = pointsOffset+(numPoints*4);
			for (j=pointsOffset; j < endPos+1; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			var startX:int = 0;
			var startY:int = 0;
			for (var i:int = 0; i < numPoints; i++) {
				var y:int = ba.readShort();
				var x:int = ba.readShort();
				trace("--------------------------------- X: " + x + " (" + uint(x).toString(16) + ")    Y: " + y + "(" + uint(y).toString(16) +")");
				if (i == 0) {
					startX = x;
					startY = y;
				}
				polygon.push(new Point(x + location.x, y + location.y));
			}
			
			polygon.push(new Point(startX + location.x, startY + location.y));
			
			trace("Got new hotspot: " + this.id + " - DestID: " + dest + " - name: " + this.name + " - PointCount: " + numPoints);
		}
		
		public function get size():int {
			return 48;
		}

	}
}