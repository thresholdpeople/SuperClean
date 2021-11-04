/* Classes that enable spawning Synths, setting up parameters (translations of their argument names to Clean abbreviations),
and grouping them with their parameters */

// Abstract Superclass of all other Modules
CleanMod : CleanLibrary { // temp name, rename CleanModule after verification
	var <>cName, <>sdName, <>params, <>dict, <>spawner;
	var <server, <verbose;

	*new { |cleanName, synthDefName, parameters, type, spawnTest| //temp name
		// cleanName == module name
		// synthDefName == SynthDef name
		// parameters == bundled SynthDef args, and SuperClean key conversions
		// type == dictionary name/entry- where to store or pull data from, typically supplied from specific addX method
		// spawnTest == boolean under test whether to spawn Synth or not (for instance effects)

		// ^super.newCopyArgs(cName, sdName, params, dict, spawn).init
		^super.new.init(cleanName, synthDefName, parameters, type, spawnTest)
	}


	init { |cleanName, synthDefName, parameters, type, spawnTest|
		// Take arguments provided from instantiation and store them as instance variables.
		// Actually store the dictionary location.

		cName = cleanName;
		sdName = type[cName][\metadata][\instrument] ?? { synthDefName };
		params = type[cleanName][\parameters] ?? { parameters };
		if(params.isKindOf(Event).not) {
			params = _.parFixer;
			params = this.parSetter(cleanName, type, params)
		};
		dict = type;
		if(spawnTest.notNil) {
			if(spawnTest.try.isKindOf(Boolean).not) { spawnTest = _.boolFixer };
			spawner = spawnTest
		};
		if(verbose) {
			// affirm success of method
		}

	}


	parFixer { |parameters|
		^parameters = parameters.asArray.asEvent
	}


	parSetter { |cleanName, type, parameters|
		cleanName = cleanName ?? { cName };
		type = type ?? { dict };
		parameters = parameters ?? { params };

		if(type[cleanName].notNil) {
			if(type[cleanName][\parameters].size == 0) {
				type[cleanName].put(\parameters, parameters)
			};
			^parameters = type[cleanName][\parameters]
		} {
			Error(
				"It is not possible to bundle parameters for '%', it does not exist yet. Check the add% methods and try again.\n".format(
					cleanName, type)
			).throw
			^this
		}
	}


	boolFixer { |test|
		^test = { test.notNil }
	}


	send { |synthName, parameters, group|
		parameters = parameters ?? { SynthDescLib.global.at(synthName).controls }; // break out to own Method? Maybe in CleanLibrary?
		parameters.asPairs.asControlInput.flop.do{ |parVal|
			server.sendMsg(\s_new,
				synthName,
				-1, // no ID
				1, // addAction: addToTail
				group,
				*parVal.asOSCArgArray // Synth's parameters
			)
		}
	}



	set {

	}


	play {

	}


	release {

	}


	resume {

	}


	free {

	}


	storeArgs {

	}


	postInfo {

	}
}

CleanSampleModule : CleanMod {

}

CleanSourceModule : CleanMod {

}

CleanInstanceModule : CleanMod {

	value { |auxBus|
		if(spawner.value) {
			// bundle all things to pass to a spawning function a-la .addModule (SuperClean.sc) and .sendSynth (CleanAux.sc)
			this.send(sdName, params)
		}
	}

}

CleanGlobalModule : CleanMod {

}

CleanMIDIModule : CleanMod {

}
