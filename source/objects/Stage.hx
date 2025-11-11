package objects;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

import data.StageData;

import Note;
import Character;

using StringTools;

class Stage extends FlxBasic{

	public var gfSpeed:Int = 1;
    public var boyfriendGroup:FlxSpriteGroup;
	public var stageBackground:FlxSpriteGroup;
	public var stageForground:FlxSpriteGroup;
    public var extraStagegroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
    public var stagescript:HaxeScript;
	public var flipdadbflayering:Bool = false;
	var stageData:StageFile;
    public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public var isPixelStage:Bool = false;
    public var charlist:Array<String> = ['dad','bf','gf'];
    public var songcharlist:Array<String> = [];
	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;
	public var dad:Character = null;
	public var gf:Character = null;
	public var curStage:String;
	public var boyfriend:Character = null;



    public function new(curStage:String,songcharlist:Array<String>)
	{
		super();
		this.songcharlist = songcharlist; 
		this.curStage = curStage;
        setupstagejson();

        
		
	}


	


    function setupscript(){
        var hxFile:String = 'stages/' + curStage + '.hx';
		trace('the hxfile is' + hxFile);
        
        if(sys.FileSystem.exists(Paths.getPreloadPath(hxFile))) {
			hxFile = Paths.getPreloadPath(hxFile);
			try{
				trace('script found!! '+ hxFile);
				stagescript = HaxeScript.FromFile(hxFile, this, false);
				stagescript.onError = PlayState.instance.hscriptError;
                PlayState.instance.hscriptArray.push(stagescript);
			}
			catch(e:Dynamic){ 
				PlayState.instance.addTextToDebug("   ...  " + Std.string(e), FlxColor.fromRGB(240, 166, 38)); 
				PlayState.instance.addTextToDebug("[ ERROR ] Could not load stage script " + hxFile, FlxColor.RED); 
			}
		}
		else if(sys.FileSystem.exists(Paths.modFolders(hxFile))) {
			hxFile = Paths.modFolders(hxFile);
			try{
				trace('script found!! '+ hxFile);
				stagescript = HaxeScript.FromFile(hxFile, this, false);
				stagescript.onError = PlayState.instance.hscriptError;
                PlayState.instance.hscriptArray.push(stagescript);
			}
			catch(e:Dynamic){ 
				PlayState.instance.addTextToDebug("   ...  " + Std.string(e), FlxColor.fromRGB(240, 166, 38)); 
				PlayState.instance.addTextToDebug("[ ERROR ] Could not load stage script " + hxFile, FlxColor.RED); 
			}
		}
		else{
			trace('no stage script found for ' + curStage);
		}
        addvarstostagescripts();
        for ( i in 0...charlist.length){
            addcharacter(charlist[i]);
        
        }
		runScriptFunction('onCreate',[]);
		trace('createstage');


    }


    function setupstagejson(){
        stageData = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		PlayState.instance.defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		if(stageData.fliplayering == null){
			stageData.fliplayering = false;
		}
		flipdadbflayering = stageData.fliplayering;

		if (stageData.camera_speed != null)
			PlayState.instance.cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		stageBackground= new FlxSpriteGroup(0, 0);
		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
        extraStagegroup= new FlxSpriteGroup(0, 0);
		stageForground= new FlxSpriteGroup(0, 0);


		add(stageBackground);
		add(gfGroup); 
		
	
		
		if(flipdadbflayering){
			add(boyfriendGroup);
			add(dadGroup);
		}
		else{
			add(dadGroup);
			add(boyfriendGroup);
		}
		
		add(stageForground);

		PlayState.instance.boyfriendGroup = boyfriendGroup;
		PlayState.instance.dadGroup = dadGroup;
		PlayState.instance.stageBackground = stageBackground;
		PlayState.instance.gfGroup = gfGroup;
		PlayState.instance.stageForground = stageForground;


        setupscript();
        
    }

    override function destroy()
		{
			runScriptFunction('destroy',[]);
			super.destroy();

		}

	

	public function runScriptFunction(id:String, params:Array<Dynamic>):Dynamic {
		if(stagescript == null) 
			return null;
 
		return stagescript.runFunction(id, params);
	}

	public function characterBopper(beat:Int)
	{
		if (gf != null
			&& beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& gf.animation.curAnim != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
			gf.dance();
		if (beat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
			boyfriend.dance();
		if (beat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
			dad.dance();

		runScriptFunction('characterBopper',[beat]);
	}
	
    function addvarstostagescripts(){
		
		addvar('stageBackground', stageBackground);
		addvar('stageForground', stageForground);
		addvar('extraStagegroup', extraStagegroup);
		addvar('boyfriendGroup', boyfriendGroup);
		addvar('dadGroup', dadGroup);
		addvar('gfGroup', gfGroup);
        addvar('addBehindGF', addBehindGF);
        addvar('addBehindBF', addBehindBF);
        addvar('addToStageBackground', addToStageBackground);
        addvar('addToStageForeground', addToStageForeground);
        addvar('addToExtraStageGroup', addToExtraStageGroup);
    }


	
    public function addcharacter(char:String = 'other'){



		var charobject:Character = null;
        switch(char){

            case 'dad':
                dad = new Character(0, 0, songcharlist[0],'dad');
				addvar('dad', dad);
		        startCharacterPos(dad, true);
		        dadGroup.add(dad);
				charobject = dad;
               
            case 'bf':
                boyfriend = new Character(0, 0, songcharlist[1], 'bf',true);
		        startCharacterPos(boyfriend);
				addvar('boyfriend', boyfriend);
		
		        boyfriendGroup.add(boyfriend);
				charobject = boyfriend;
             
            case 'gf':
                if (!stageData.hide_girlfriend)
                    {
                        gf = new Character(0, 0, songcharlist[2],'gf');
                        startCharacterPos(gf);
                        gf.scrollFactor.set(0.95, 0.95);
                        gfGroup.add(gf);
						addvar('gf', gf);
						charobject = gf;
                        
                    }
}


        runScriptFunction('characterCreation',[charobject]);


       
    }


	 
	public function startCharacterPos(char:Character, gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}
	
	public function addvar(name:String, value:Dynamic) {
        if (stagescript != null) {
            stagescript.interpreter.variables[name] = value;
        }
    }


public function add(obj:FlxBasic){
	FlxG.state.add(obj);

}


	
    public function addBehindGF(obj:FlxSprite):Void {
        if (gfGroup == null || obj == null) return;
        var index = gfGroup.members.indexOf(gf);
        if (index == -1) index = 0;
        gfGroup.members.insert(index, obj);
    }

   
    public function addBehindBF(obj:FlxSprite):Void {
        if (boyfriendGroup == null || obj == null) return;
        var index = boyfriendGroup.members.indexOf(boyfriend);
        if (index == -1) index = 0;
        boyfriendGroup.members.insert(index, obj);
    }

 
    public function addBehindDad(obj:FlxSprite):Void {
        if (dadGroup == null || obj == null) return;
        var index = dadGroup.members.indexOf(dad);
        if (index == -1) index = 0;
        dadGroup.members.insert(index, obj);
    }

    
    public function addToStageBackground(obj:FlxSprite):Void {
        if (stageBackground == null || obj == null) return;
        stageBackground.members.insert(0, obj);
    }

   
    public function addToStageForeground(obj:FlxSprite):Void {
        if (stageForground == null || obj == null) return;
        stageForground.add(obj);
    }

    
    public function addToExtraStageGroup(obj:FlxSprite):Void {
        if (extraStagegroup == null || obj == null) return;
        extraStagegroup.add(obj);
    }



    
}