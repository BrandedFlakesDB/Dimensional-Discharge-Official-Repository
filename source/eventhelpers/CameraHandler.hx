package eventhelpers;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import PlayState;
import Character;

using StringTools;

class CameraHandler
{
	static public var cameraTwn:FlxTween;
	static public var zoomTwn:FlxTween;

	static public function handelcameramovement(value1:String, value2:String)
	{
		var focous:String = '';
		var character:Character = null;
		var offsets:Array<Float> = [];
		var ease:String = '';
		var characteroffsets:Array<Float> = [];
		var valuearray:Array<String> = value1.split(',');
		var valuearray2:Array<String> = value2.split(',');
		var time:Float = 4;

		if (valuearray.length > 0 && valuearray[0] != null)
		{
			switch (valuearray[0].toLowerCase().trim())
			{
				case 'dad', 'd', 'opponent':
					character = PlayState.instance.stage.dad;
					characteroffsets = [150, -100];
					focous = 'dad';

				case 'bf', 'boyfriend', 'player':
					character = PlayState.instance.stage.boyfriend;
					characteroffsets = [-100, -100];
					focous = 'boyfriend';

				case 'gf', 'girlfriend':
					character = PlayState.instance.stage.gf;
					characteroffsets = [-100, -100];
					focous = 'girlfriend';

				default:
					trace('WARNING. IMPROPER USAGE OF THE CHARACTER FIELD!! DEFAULTING TO DAD');
					character = PlayState.instance.stage.dad;
					characteroffsets = [150, -100];
					focous = 'dad';
			}
		}
		else
		{
			trace('WARNING!!! EVENT NOT USED PROPERLY, VALUE 1 MUST BE IN THIS ORDER CHARACTER, CAMOFFSET. STOPPING EVENT.');
			return;
		}

		for (i in 1...3)
		{
			if (valuearray.length > i)
			{
				var parsed:Float = Std.parseFloat(valuearray[i]);
				if (!Math.isNaN(parsed))
					offsets.push(parsed);
				else
					offsets.push(0);
			}
			else
				offsets.push(0);
		}

		
		if (valuearray2.length > 0)
		{
			var first:String = valuearray2[0];
			var firstFloat:Float = Std.parseFloat(first);
			if (Math.isNaN(firstFloat))
				ease = first;
			else
			{
				trace('No value 2 easing. defaulting to linear. doing time code instead');
				time = cameratime(firstFloat);
				ease = 'linear';
			}
		}

		if (valuearray2.length > 1)
		{
			var second:Float = Std.parseFloat(valuearray2[1]);
			if (!Math.isNaN(second))
				time = cameratime(second);
			else
			{
				trace('No value 2 timing. defaulting to 4');
				ease = 'linear';
			}
		}

		
		if (cameraTwn != null)
		{
			cameraTwn.cancel();
			cameraTwn = null;
		}

		PlayState.instance.setFunctionOnScripts('onMoveCamera', [focous]);
		cameraTwn = FlxTween.tween(
			PlayState.instance.camFollow,
			{
				x: character.getMidpoint().x + characteroffsets[0] + character.cameraPosition[0] + PlayState.instance.stage.opponentCameraOffset[0] + offsets[0],
				y: character.getMidpoint().y + characteroffsets[1] + character.cameraPosition[1] + PlayState.instance.stage.opponentCameraOffset[1] + offsets[1]
			},
			time,
			{
				ease: HaxeScript.getFlxEaseByString(ease),
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			}
		);
	}



	static public function cameratween(value1:String, value2:String,camZooming:Bool ){


		var valuearray:Array<String>  = value2.split(',');
		var ease:String = 'linear';
		var time:Float = 4;
		var zoom:Float = 0;
		if(value1 != ''){
			ease = value1;
		}

		if(valuearray[0] != null){
			time = Std.parseFloat(valuearray[0]);
		}
		if(valuearray[1] != null){
			zoom = Std.parseFloat(valuearray[1]);
		}
		else{
			zoom = PlayState.instance.defaultCamZoom;
		}

		if (zoomTwn != null)
		{
			zoomTwn.cancel();
			zoomTwn = null;
		}
		
		trace('camzooming: ' + camZooming);
		switch(camZooming){
			case true:
				zoomTwn = FlxTween.tween(PlayState.instance, {defaultCamZoom: zoom},cameratime(time), {ease: HaxeScript.getFlxEaseByString(ease),onComplete: function(twn:FlxTween)
						{
							zoomTwn = null;
						}}); //woaaaah});


			case false:
				zoomTwn = FlxTween.tween(FlxG.camera, {zoom: zoom},cameratime(time), {ease: HaxeScript.getFlxEaseByString(ease),onComplete: function(twn:FlxTween)
						{
							zoomTwn = null;
						}}); //woaaaah});
		}

	}

	static function cameratime(offset:Float):Float
	{
		return Conductor.stepLengthMs * offset / 1000;
	}
}
