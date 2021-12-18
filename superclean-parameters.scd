/*
# Intro

SuperClean is a collection of sound generating and manipulating modules and routing schemes.  These modules are controlled with SuperCollider's Pattern classes.

Modules which generate sound, or allow live inputs to be used are referred to as SoundSources.  These are used to inject sonic material into the signal chain.

Modules which are then used to further manipulate and control this material come in two flavors: InstanceEffects and GlobalEffects.

- InstanceEffects are created for each iteration of a running Pattern (actually for each Event instance), and are all routed in series.

- GlobalEffects are routed in parallel and receive the post-InstanceEffects signal of all still playing Events.  There is a matching set of GlobalEffects per AuxBus, and ypu can have as many Aux Buses as your computer can handle, if necessary.  Each Aux Bus can be configured to output to SuperCollider's main outputs, or it can be routed to other output channels for multichannel speaker setups or different routing schemes.
  - Aux Buses are typically initialized in your startup file, specifically by the providing an instance of SuperClean the start message, with an array of outputs.
    - For example: ~clean.start([0, 2, 4]) creates 3 Aux Buses, with their outputs set to channels 1 & 2, channels 3 & 4, and channels 5 & 6, output buses in SuperCollider, respectively.  Theses commonly will correspond to one's audio interface, or other out-of-SuperCollider and into-something-else channels.
      - The startup file example code: ~clean.start([0, 0, 0]) creates 3 Aux Buses, all routed to output channels 1 & 2.  This is maybe the default, and allows for up to 3 parallel streams of GlobalEffects which get mixed and output to your audio interface's main outs

We will dig deeper into Patterns and Events below.


SuperClean's modules use unique three-letter combos to for each parameter of each module.  It is also possible to use a SynthDef's Control argument name.

- Techincally: all SoundSources, InstanceEffects, and GlobalEffects are SynthDefs within SuperCollider, and use specific methods to set them up for easy use in SuperClean and to translate more traditional Control argument names into the three-letter-combos.  It is possible to add your own to each of these types of modules.  Instructions on how to do this are forthcoming, but looking over the files in SuperClean's Modules folder should provide examples on how to currently do this.

Certain parameters are also available for controlling aspects of a Pattern or Event, for example to set the timing for when the next Event should occur (kind of like the step-length), or the scale and tuning for a set of pitches.

To set or control a specific parameter, set a value for its name within a Pattern.  This value can be a static number, or it can be a different Pattern, or other bit of code, or combinations of these!

And just like when using patterns outside of SuperClean, it's also possible to create your own parameter names in a running pattern.  Think of these as variables.  These variables can be referenced later in that pattern.  The values of the parameters can be set or created in the exact same way as any other parameter: a static number, a pattern, or other type of code, or combinations of these.


We recommend using Pdefs as the main pattern creation and control methods because of how straightforward it is to update parameter values, and make changes on the fly.  Though this isn't strictly necessary!


Below is a guide to the various modules and their parameters, as well as specific parameter names which are also common and/or useful in patterns.

We'll cover pattern parameters first, then SoundSources, then InstanceEffects, and finally GlobalEffects.

- The pattern parameters section will largely be concepts which apply to using Patterns in SuperCollider.  There are several existing resources which go into much depth about Patterns and Events, so the guide below will focus on how to set up a pattern to use SuperClean paradigms.

Most, but not all values for parameters are set to be values between 0.0 to 1.0, unless otherwise indicated.  Occasionally even though a parameter is configured to receive 0.0 to 1.0 values, different numbers can be provided for creative results.  The simplest example is setting the amplitude of a module to be greater than 1.0 in order to distort the signal.
- Speaking of distortion, the final module in each Aux Bus's signal chain contains a limiter which will provide crunchy distortion while also saving your ears!

Also check out the Resources.md file included in the SuperClean folder for links to other guides, tutorials, and useful resources.






# Patterns

## Common Pattern Parameters:


Each time a Pattern runs through all the parameters and their values, it will create what's called an Event.  A simple way to consider this is that a Pattern is like a sequencer, and an Event is what happens at each each step.  Put a different way: Patterns are a set of instructions or score, and Events are the execution of those instructions or playback.

Depending on certain values, events can either overlap each other, or cut each other off, which means that certain sounds can continue to ring out, even though the sequence has moved on.

Furthermore, not every parameter needs to be explicitly stated in a Pattern.  Many parameters have default values, and so if a parameter is not specifically set in a pattern, but the value for that parameter is actually important, its default value will be used.  This may sound a bit confusing, but it actually allows you to write Patterns which do not require many lines of code, yet still function.


As mentioned, Pdef is one of the most straightfoward ways to create a playing Pattern which can be modified over time.

- A Pdef - "Pattern Definition" - most typically receives two arguments (defined settings or values):
  - (1), a unique name.  You can have many Pdefs which must be have different names; creating a Pdef that has the same name as a different Pdef will actually cause the former to be overwritten by the latter.  This can be used as a strategy for working with sonic material.
  - (2), a Pbind - a pattern which "Binds" together parameters (also referred to as keys) and their values as pairs.  This is how values are set for various parameters, and this ultimately is what provides the instructions for Event creation.

- The Pbind is "nested" within the Pdef, and it in turn nests the coupling of parameters and values.  These values may be other types of Patterns, and may even be Patterns which nest other Patterns within themselves.

Explore the help file for more specifics, but below is a boilerplate block of code:

*/
```
Pdef.help // < evaluate this line

(
Pdef(\name,
	Pbind(*[
		type: \cln,
		snd: \sin,
		freq: 440,
		dur: 1.0,
		amp: 0.3
	])
).play
)
```
/*

As a brief overview, \name is a Symbol, and it can be any unique Symbol, eg: \bass, \kicks, \drones, or even an Integer.  It can also be defined in single-quotes: 'name', or even double-quotes: "name".

.play is a "message" which is sent to the Pdef (the Pdef's contents are between two parenthesis, and .play is appended to them).  This message tells the Pdef to play!
- It will continue to play until either:
  - (1), it receives a stop message-
    - Evaluating Pdef(\name).stop on a new line of code, or in the above code block: deleting/replacing the word "play" with the word "stop"and re-evaluating that block.
  - (2), it runs out of values to provide for at least one parameter (within the nested Pbind).
    - Running out of values is the equivalent to having to set a parameter's value to nil, and in the example above, there is no chance for that.
  - (3), you press key combination to stop ("kill") all processes
    - This combo is: command + period on Macs, control + period on Windows, meta + period on Linux systems by default

You can have several Pdefs ".play"ing at the same time, so long as each Pdef has a unique name.  As mentioned above, if a Pdef shares the same name as a different Pdef, it will overwrite its definition, effectively replacing the block of code it contains.  This can also be used as a compositional or performative strategy!

Pbind does most of the actual work of setting parameters and their values. You might see Pbinds written in a couple of ways in various documentation or code:

*/
```
// the most common way in SuperClean examples:
(
Pdef(\name,
	Pbind(*[
		type: \cln,
		snd: \sin,
		freq: 440,
		dur: 1.0,
		amp: 0.3
	])
).play
)

// the most common way in many other Pattern examples:
(
Pdef(\name,
	Pbind(
		\type, \cln,
		\snd, \sin,
		\freq, 440,
		\dur, 1.0,
		\amp, 0.3
	)
).play
)
```
/*

Both blocks above are functionally equivalent, and it's a matter of taste on how you want to write things.  The only thing is you can't mix and match styles _within the same Pbind!_
- You might also commonly find examples of Pbinds which are not nested in Pdefs at all in documentation outside of SuperClean.

Pbinds "bind" together a list of Key Value Pairs. That is, a list of parameters and their associated settings/values.

In the above examples each pair of keys (parameters) and their values (settings) are on the same line (though strictly speaking, they do not have to be).

Some of the key value pairs above are specific pattern parameters, while others are specific to a module.

The block of code above will create a SuperClean Pattern, which will generate a SoundSource called \clean_sine every 1.0 seconds. Each generated instance of \clean_sine will play at 440Hz, with an amplitude of 0.3.


We'll go through the essential Pattern parameters now, and then end with some other types that can be useful. For our examples, we'll use the parameter colon value comma structure.. we find this to be more readable. eg:
type: \cln,
snd: \sin,
freq: 440,

Also, from here on out, when you read the word Pattern, it will imply a Pbind nested within a Pdef.  Though, for more advanced use, there are other possibilities that are outside the scope of this guide...




## Setup Parameters:


*/
```
type: \cln,
```
/*  This specifies that it this is a "SuperClean Pattern" type. Types more or less alert patterns to particular parameter names theys should respond to, and any default values which they may already have.
Set this to \cln.  \cln means SuperClean.
- If you omit this line, things will not function correctly.  Therefore it's most typical to put it as the first line of your Pattern.


*/
```
snd:
```
/*  Provide it the name of the SoundSource you will use.  The name should be formatted as a Symbol (first character is a backslash - \sourceName - or inside of single quotes - 'sourceName'.
- In the above example \sin is SuperClean shorthand for \clean_sine, which is the name of a specific SynthDef.
  - There are many types of SoundSources already built in to SuperClean.  Many are synthesizers, and others are sample players, and a few are processors which allow you to receive audio input from either other running processes in SuperCollider or from your audio interface.
- This can even be a pattern which allows the SoundSource to change from one event to the next! Eg: Pwrand([\sin, \saw], inf)


Technically, the bare minimum amount of information a SuperClean Pattern will require is type and snd.  It will provide default values for any other parameter of consequence.  A few examples:

*/
```
(
Pdef(0, // name of the Pdef, note that it is set to an Integer.  You will find many SuperClean examples which use this naming convention
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \saw // creates (plays) a triangle-saw variable wave synthesizer with default frequency, envelope, and amplitude values for each Event
	])
).play
)

// or

(
Pdef(0, // note that evaluating this block of code effectively overwrites the previous one, as they share the same name!
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \mmd, // \mmd is the default sample pack which comes with SuperClean.  This creates (plays) the default sample from the pack, at the default playback speed, with default envelope and amplitude values for each Event
	])
).play
)
```
/*

From here it is possible to expand these patterns, adding, for example, using the freq or rel keys for the \saw synthesizer to control its frequency or envelope release time, respectively.  Or for the sample player, using the num or spd keys to control which sample to play and its playback speed, respectively.

*/
```
(
Pdef(0, // name of the Pdef, note that it is set to an Integer. You will find many SuperClean examples which use this naming convention
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \saw, // creates (plays) a triangle-saw variable wave synthesizer
		freq: Pseq([300, 600, 420, 210], inf), // creates a sequencer for frequency, on the first step 300Hz, on the second step 600Hz, etc
		rel: Phprand(0.8, 3.0), // randomly choose a release time between 0.8 and 3 seconds, with preference given to higher values, for each step
	])
).play
)

// or

(
Pdef(0, // note that evaluating this block of code effectively overwrites the previous one, as they share the same name!
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \mmd, // \mmd is the default sample pack which comes with SuperClean
		num: Pwhite(0, 12), // randomly choose a sample from the pack (there are 13 samples total in the pack; the count starts with 0)
		spd: Prand([1, 0.5, 2], inf), // randomly pick a playback speed from the list: either the default rate (1), half speed and down one octave (0.5), or twice the speed and up one octave (2)
	])
).play
)
```
/*

Check out the SoundSources section for a list and description of all the available parameters for each SoundSource.




## Timing Parameters:


### As They Pertain to an Event:

Patterns run on an instance of TempoClock, and unless you explicitly set it, it is both the default TempoClock - TempoClock.default - with a default setting of 60 beats-per-minute.  Within patterns, there are several layers of control over timing.  Ultimately they control either the length of each step within a Pattern or the length of time of each Event (technically these are not the same thing), or both.


*/
```
dur:
```
/*  This is kind of like the length of each step, but more accurately the length of time until the next step (Event).
- Any floating point number greater than 0 can be used.
  - The default dur value is 1.0.  Which means that if dur is not explicitly set, its implied value is 1.0.


*/
```
stretch:
```
/*  This is a scaling factor for dur.  dur: 1, stretch: 0.5 is equivalent to just setting dur to be 0.5.  So actually, the length of time until the next step (Event) is defined by:  dur * stretch.
- Any floating point number greater than 0 can be used.
  - The default stretch value is 1.0.  Which means that if stretch is not explicitly set in a Pattern, its implied value is 1.0.


*/
```
delta:
```
/*  This is either implicitly created by using (providing values for) either/both dur and stretch (remember both have default values, so just because you didn't specify a value for the parameter doesn't mean it's not actually being used), or a value for delta can be explicitly provided, which means that it will override any values set for dur and/or stretch.
- Any floating point number greater than 0 can be used.
  - The default delta value is calculated by:  delta = dur * stretch


Because of the default tempo (60 BPM), there are two simple way to think about musical timing.  delta: 1 can correspond to either one beat or one bar (though _technically_ it corresponds to one beat).
- So that dur: 0.5 either signifies an eigth note or a half note; 0.25 is one-sixteenth or a quarter; 2.0 is either a half note or two bars, etc.

You will rarely see delta explicitly used as a key in SuperClean examples.  Most commonly you'll see dur and stretch, but remember that:  delta = dur * stretch, so it is always implied.

Some simple examples of this:

*/
```
(
Pdef(0, // name of the Pdef, note that it is set to an Integer. You will find many SuperClean examples which use this naming convention
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \saw, // creates (plays) a triangle-saw variable wave synthesizer with default frequency, envelope, and amplitude values for each Event
		dur: 0.5 // sets duration to be 2 beats long (stretch is implied, with a value of 1.0.  dur * stretch = delta. 0.5 * 1.0 = 0.5)
	])
).play
)

(
Pdef(0, // name of the Pdef, note that it is set to an Integer. You will find many SuperClean examples which use this naming convention
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \saw, // creates (plays) a triangle-saw variable wave synthesizer with default frequency, envelope, and amplitude values for each Event
		dur: 0.5,
		stretch: 0.5 // scales dur by 0.5, effectively setting duration to be 1 beat long / the time until the next Event to be 0.25
	])
).play
)

(
Pdef(0, // name of the Pdef, note that it is set to an Integer. You will find many SuperClean examples which use this naming convention
	Pbind(*[
		type: \cln, // sets this Pbind to be a SuperClean Pattern
		snd: \saw, // creates (plays) a triangle-saw variable wave synthesizer with default frequency, envelope, and amplitude values for each Event
		dur: 0.5,
		stretch: 0.5,
		delta: 2, // by explicitly using this parameter, dur and/or stretch are ignored. This currently sets the duration to be 2 beats long
	])
).play
)
```
/*


### As They Pertain to Modules:

There are two other parameters which deal with timing:
- legato
- sustain

These parameters manipulate the potenial amount of time each Event can exist - which can be less than, equal to, or greater than the amount of time specified by delta, or dur * stretch, until the next Event is created.

Effectively these parameters allow for events to either end prematurely, or ring out and overlap with other, future events.  Though they do not cause future events to happen sooner or later - that is specifically control by delta, dur, and/or stretch.


*/
```
legato:
```
/*  This is a scaling factor which allows you to specify how long to "hold" the Event.  It is relative to the duration of each Event.
- 1.0 means that the Event will exist for the same length as the duration of the Event.
- 0.5 means that the Event will exist for half the duration, theoretically cutting the Event short.
- 2.0 will allow the Event to exist for twice its duration, so it will theoreticaly overlap with the next created Event.
  - The word "theoretically" is used because legato does not actually stretch a SoundSource's amplitude envelope, so it may still decay to silence before the Event itself ceases to exist.
- Any floating point number greater than 0 can be used.
  - The default value is 1.0.


*/
```
sustain:
```
/*  This specifies - in beats - how long to "hold" the Event.  After X beats, a release message is sent to all the modules created by that Event, which will cause them to go into the release portion of their amplitude envelopes, should they have them.
- The same caveat applies here as legato.  Depending on the actual amplitude envelope, and its settings this may not have an audible effect as the modules for that Event may have already faded out.
- Any floating point number greater than 0 can be used.
  - Unless set explicitly, it is calculated by:  dur * stretch * legato (in otherwords, delta * legato).




## Pitch Parameters:


Determining how a given SoundSource, or other relevant module, reacts to frequency or pitch must technically be done within the SynthDef which defines that module.

Most commonly, freq is the name of the Control argument used to do so in SynthDefs.  Most SoundSources (but not all, eg: /drm, /hat, and /clp) provide freq as an argument name.  Sometimes effects may do so as well, when applicable (\fsh - a frequency shifter).

However, this is in the Pattern section because there are a bunch of what may be considered "convenience" parameters that simplify deriving pitch and/or frequency values that need-not be defined in a module's SynthDef at all.


First, the freq key will be explained:

*/
```
freq:
```
/*  This explicitly specifies the frequency for compatible modules.  Typically this will be a SoundSource, however a few notable InstanceEffects also use this parameter (\fsh).
- Any floating point number between 20 and 20,000 can be used.
  - Values outside of this range will be clipped to fit.
  - The default value is 440.

freq is the highest level of all these other parameters described below.  This means (just as in the case of delta, and dur and/or stretch):
- freq can be derived from lower level parameters.
- Setting a value for freq within a pattern will effectively cause it to ignore any other related lower-level-parameter settings.


All the other parameters are ultimately converted into freq by underlying pattern mechanisms, and then that value is sent to relevant modules, to their freq parameter.

This is am important consideration because it means that none of these other parameters will do anything for modules that do not have freq as an argument!

Furthermore, these other parameters, just like freq relative to them, also have a hierarchy, and they will behave in the same way as freq does:
- Certain parameters may be derived from lower level parameters.
- Setting a value for a higher level parameter within a pattern will effectively cause it to ignore any other related lower-level-parameter settings.


This next chunk will cover three parameters:
- midinote
- ctranspose
- harmonic

Together these three are converted into freq by the following formulation:  freq = (midinote + ctranspose).midicps * harmonic


*/
```
midinote:
```
/*  This allows you to use a MIDI note to specificy the frequency for compatible modules.
- 60 is middle C.
  - Using midinote is equivalent to writing:  freq: 60.midicps
    - midicps is a message which can be passed to numbers to convert from MIDI notes to cycles-per-second.
- Any floating point number greater than 15 and less than 135 can be used.
  - These are not technically "pitch values"!  Just a convenient way to derive frequency, so that's why 60.5 can be used.
  - The default value is 69.0, eg: 440 Hz.


*/
```
ctranspose:
```
/*  "Chromatic transpose", this is an offset which can be considered in pitch.  It will be added to midinote to provide the final note value which then gets converted into frequency and sent to compatible modules.
- Any positive or negative floating point number can be used.
  - This number will be converted to Hertz and added to the frequency which is sent to compatible modules.
  - The default value is 0.0, eg: no offset.


*/
```
harmonic:
```
/*  Scaling factor applied to:  (midinote + ctranspose).midicps, this allows for further transposition around a given harmonic ratio.
- Any floating point number greater than 0 can be used.
  - The default value is 1.0.


The next level down builds midinote from the following parameters, all focused around how scales formed from groups of notes:
- note:  determines pitch as a scale degree
- gtranspose:  gamut transposition; 0.0 is the default
- stepsPerOctave:  how many note units fit within an octave; 12 is the default
- octave:  octave offset; 5.0 is the default (middle C octave)
- root:  the root of the scale; default is 0
(all values provided may be floats)

Together these are converted into midinote by the following formulation:  midinote = ((note + gtranspose + root) / stepsPerOctave + octave) * 12.0

If this is obscure when written out like this, then perhaps going straight ahead to the next level down will hopefully make things more clear.

This level is builds note from the following parameters, all focused on how a note may be distinct from other notes:
- degree:  the degree within a scale; 0 is the default
- mtranspose:  modal transposition; 0 is the default
- scale:  mapping of scale degrees into semi-tones, eg: Major is [0, 2, 4, 5, 7, 9, 11], which is also the default
- stepsPerOctave:  same parameter as the above level, but it also plays a role here; default is still 12
(all values provided may be floats)

Together these are converted into note by the following formulation:  note = (degree + mtranspose).degreeToKey(scale, stepsPerOctave)

Here are some examples of various combinations (note the use of Value Patterns to derive values for some parameters):

*/
```
(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \sqr,
		freq: Pseq([200, 350, 550, 425], inf), // using only freq, not sticking to scales or notes
		dur: Pseq([1, 0.5, 1, 0.25], inf)
	])
).play
)

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \sqr,
		midinote: Pseq([55.35, 65.04, 72.86, 68.4], inf), // pedantic example to show how midinote does not need to be provided integers
		dur: Pseq([1, 0.5, 1, 0.25], inf)
	])
).play
)

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: Pseq([\sqr, \saw], inf),

		dur: Pseq([0.25, 0.25, 0.5, 0.375, 0.25], inf),
		stretch: Pdup(Pseq([40, 20], inf), Pseq([1, 0.5], inf)),

		legato: Prand([0.75, 1, 1.5, 3], inf),

		midinote: Pseq([50, Prand([57, 47]), 62, 67, 75], inf),
		ctranspose: Prand([-12, 0, 12], inf), // randomly transposing by 12 semi-tones
		harmonic: Pdup(8, Pseq([1, 1.3, 1.7, 2.1, 2.5], inf)), // slowly twisting out of tune

		// amplitude envelope parameters for both \saw and \sqr
		atk: Pwhite(0.001, 0.1), // attack time
		rel: Pwhite(0.7, 2.0), // release time
		tsc: 2, // "timeScale" scale factor for envelope times
	])
).play
)

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: Pseq([\sqr, \saw, \fmx], inf),

		dur: Pseq([0.25, 0.25, 0.5, 0.125, 0.375, 0.5], inf),
		stretch: Pdup(24, Pseq([1, 0.5], inf)),

		legato: Pkey(\stretch) + Pdup(Pwhite(1, 3), Pwhite(0, 1)),

		degree: Pbrown(-7, 7, Pn(Pseries(1, 1, 7), inf)),
		scale: Scale.pelog,
		mtranspose: Pseq([-5, 5], inf), // up and down an octave
		stepsPerOctave: Pwhite(7, 12),

		rel: Pwhite(1, 3) + Pkey(\stretch),
		wid: Pseg([0, Pkey(\dur)], 3, -2, inf),
	])
).play
)
```
/*

To find out more about Scales and Tuning, see their help files.  And look through their respective directories to see which choices are available:

*/
```
Scale.help
Tuning.help

Scale.directory
Tuning.directory
```
/*

To provide a scale to the scale parameter, you can write Scale.nameOfScale as its value (it's also possible to have random or sequencable changes to this.  For a scale with a non-standard tuning, you can write Scale.nameOfScale(\nameOfTuning) as the value for scale.

To see what the degrees and tuning offsets are for a specific choice, you can evaluate that Scale:

*/
```
Scale.pelog
```
/*




## Multichannel Expansion:


Multichannel expansion allows for multiple simultaneous voices.  This could allow you to build complex tones by specifying several different frequencies for a SoundSource, or various spatialization effects.

It works works with most, but not all, parameters.  Multichannel expansion functions at the Instance level, which means that it can be used with SoundSources and InstanceEffects, but **not** GlobalEffects.

Technically, multichannel expansion creates multiple copies of the same SoundSource or InstanceEffect, and provides each copy with potentially-unique parameter values.

To use it, provide a valid parameter with an array of values.  The values can be static numbers or even various pattern types!  The amount of values in the array (the size of the array) specifies how many voices to create.  It is not necessary to provide arrays for all parameters for the expanded SoundSource or InstanceEffect (in this case, any key which that does not have an array will provide the single value to all instances).

*/
```
(
Pdef(0, // approximating a square wave with multichannel expansion
	Pbind(*[
		type: \cln,
		snd: \sin,
		freq: [100, 300, 500, 700, 900], // will create 5 simultaneous instances of the \sin SoundSource
		amp: 0.2, // not providing an array here means that all 5 instances will use the same value
	])
).play
)

(
Pdef(0, // approximating a square wave with multichannel expansion, better
	Pbind(*[
		type: \cln,
		snd: \sin,
		freq: [100, 300, 500, 700, 900], // will create 5 simultaneous instances of the \sin SoundSource
		amp: [0.3, 0.27, 0.24, 0.21, 0.18] // each value will be passed, in order, to each respective instance
	])
).play
)

(
Pdef(0, // approx square wave with progression
	Pbind(*[
		type: \cln,
		snd: \sin,
		freq: [100, 300, 500, 700, 900] * Pseq([1, 0.5, 1, 2.5, 1.25, 0.8], inf),
		amp: [0.3, 0.27, 0.24, 0.21, 0.18],
		rel: Pseq([0.8, 0.6, 0.9, 1.1], inf), // all instances receive the same release time
		dur: 0.125,
	])
).play
)
```
/*

Certain parameters cannot be expanded:
- type
- snd:  To have multiple yet different SoundSources at the same time you must use separate patterns running in parallel
- dur:  This must also be broken out into separate parallel patterns

Attempting to expand these parameters will crash the Interpreter.  If this happens go to the Language drop-down menu and select Reboot Interpreter.

It is however possible to have multiple simultaneous samples within the same pattern:

*/
```
(
Pdef(0, // approximating a square wave with multichannel expansion
	Pbind(*[
		type: \cln,
		snd: \mmd, // built-in sample
		num: [0, 15, 14],
		amp: [0.3, 0.4, 0.4],
		pan: [0.0, 0.5, 1.0],
		atk: [0.01, 0.2, 0.001],
	])
).play
)
```
/*




## Playing Patterns:


### play, stop, and reset Messages:

Thus far, all the examples have called play on the Pdef while evaluating the contents of the code inside it.  But sometimes you might want to evaluate a pattern without necessarily playing it immediately (or even sometimes at all!)

It's possible to evaluate a pattern without play-ing it immediately.  Likewise, it's also possible to stop it.  Or reset it (which is like going back to the beginning of the code without any wait).

*/
```
(
Pdef(0, // create Pdef named 0, and define what the code is inside of it:
	Pbind(*[
		type: \cln,
		snd: \fmx,
		dur: Pseq([0.3, 0.2, 0.2, 0.3], inf),
		degree: Pseq([0, 3, -7], inf),
		legato: Pwrand([1, 0.8, 0.2], [0.8, 0.1, 0.1], inf),
	])
)
)

Pdef(0).play // play it
Pdef(0).stop // stop it
Pdef(0).reset // reset it
```
/*


### Quantization:

You can also quantize when a Pattern starts playing after receiving a play message, when newly evaluated code kicks in, when the pattern stops after receiving a stop message, etc.  Quantization is set relative to the TempoClock the pattern is running on, and it's set in beats, or delta-time.

There are a couple of ways to set the quantization, the most immediate way being as an argument provided with a play message, though there is a major drawback in doing it like this...

*/
```
Pdef(0).play(quant: 2) // quantize to two beats (depending on how you want to count time)
```
/*

Setting quantization like this seems to only quantize it start that one time.  It's possible to see the Pdef's quantization time by providing the Pdef with a quant message:

*/
```
Pdef(0).quant // this returns 1 upon evaluation! 1 is the default.

// Set quantization to 2:
Pdef(0).quant = 2

Pdef(0).quant // returns 2 on evaluation

// Now all code changes/re-evaluations will also be quantized:
( // assumes Pdef(0) is already playing
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \fmx,
		dur: Pseq([0.3, 0.2, 0.2, 0.3], inf),
		degree: Pseq([0, 3, -7], inf),
		legato: Pwrand([1, 0.8, 0.2], [0.8, 0.1, 0.1], inf),
		stretch: Pdup(16, Prand([0.5, 1, 1.5], inf)),
		rel1: 5 + (Pkey(\stretch) * Prand([1, -1], inf)),
		amp: 0.2,
	])
)
)
```
/*


### fadeTime:

When a Pdef is re-evaluated and discovers new code it sends release messages to all the active Events as a way of smoothly stopping them.  It also creates all new events based on the new code.  Both of these things are done at the same time, and this action can be quantized.

Even smoother transitions can be possible: the Pdef can fade-out any SoundSources and InstanceEffects in old, still-active Events, and fade-in new ones.

Note that for this to work, all modules will need to have an amp Control argument to set amplitude, at the SynthDef level (SynthDefs _can_ have different parameter names that are then translated into three-letter abbreviations that are typical to SuperClean).

How long this takes is set via providing the Pdef a fadeTime message.

*/
```
Pdef(0).fadeTime // evaluating this code will return what the current fadeTime is set to

Pdef(0).fadeTime = 0.1 // set fadeTime to 0.1

// Now old Events will fade out while new ones will fade in
( // Run this block a bunch of times
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: Pdup(inf, Pxrand([\dfd, \saw, \sqr, \sin, \fmx], inf)),
		scale: Scale.harmonicMinor,
		degree: Pdup(inf, Plprand(0, 7)),
		octave: Pdup(inf, Plprand(4, 7)),
		wid: Pdup(inf, Plprand(0.01, 0.5)),
		pan: Pdup(inf, Pmeanrand(0.0, 1.0)),
		amp: Pwhite(0.125, 0.5),
		dur: 1/8,
	])
).play;
Pdef(0).fadeTime = 8.0;
)
```
/*


### Clocking:

Patterns default to play on the default TempoClock, which can be called and manipulated by sending messages to TempoClock.default.

By default, it runs at 60 beats per minute.  But note that it is set in beats per second!

*/
```
TempoClock.default.tempo // evaluting this returns a beats per second value

TempoClock.default.tempo = 2 // sets to 120 BPM, or 2 BPS

TempoClock.default.tempo = (80 / 60) // formula to work in BPM (desired BPM / 60 seconds)

TempoClock.default.beatDur // evaluating this returns how long each beat is, in seconds
```
/*

It's also possible to create new TempoClocks, and set Pdefs to run on them:

*/
```
~newClock = TempoClock(100 / 60).permanent_(true) // create a new TempoClock that's set to 100 BPM, and make sure it survives cmd-period
```
/*

The ".permanent_(true)" part is very important!  If TempoClock is created without it, pressing cmd/ctrl/meta-period (to kill everything currently running on the Server) also removes this clock.  If permanent is set to true, then the clock will persist.

The name "~newClock" is nothing special or specific.  You can use any other variable name you desire.

*/
```
~newClock.tempo // returns 1.666 BPS

~newClock.beatDur // returns 0.6 seconds per beat
```
/*

In order for a Pdef to become associated with a clock, it cannot currently be playing.

When a Pdef is stopped there are two ways to specify which clock to use:
- An argument provided in the play message (it is the first argument in play)
- Sending the Pdef itself a clock message, and setting it equal to the Clock

*/
```
// If the Pdef is already stopped, either:
(
Pdef(0).clock = ~newClock;
Pdef(0).play
)
// Or
Pdef(0).play(~newClock)

// It is then possible to change the tempo, etc, as per usual.
~newClock.tempo = 7


// It's possible to have different Pdefs playing on different Clocks!

( // Pdefs run on TempoClock.default, by default
Pdef(1,
	Pbind(*[
		type: \cln,
		snd: \saw,
		amp: 0.65,
	])
).play
)
TempoClock.default.tempo = 0.75 // change the tempo of the default TempoClock without changing ~newClock's tempo
```
/*

It is also possible to change the tempo directly inside of a running pattern by using the tempo key.  This means that, just like for most other parameters, other patterns can be used to generate a value!

*/
```
// evaluate this first! create a new clock for this pattern, set to 60 BPM
~clock = TempoClock(1).permanent_(true)
( // now this
Pdef(2,
	Pbind(*[
		type: \cln,
		snd: \saw,
		amp: 0.65,
		tempo: Pseg([1, 10], 10, \lin, inf),
	])
).play(~clock)
)
```
/*

Keep in mind that this way of controlling the tempo _does not_ create a new and dedicated clock for the running pattern.  This means that providing the tempo key a value inside of the pattern actually updates the tempo for the respective clock!

Evaluate this line below to confirm, both during the Pdef(2)'s playback and also when stopped:
*/
```
Pdef(2).play(~clock)

~clock.tempo // evaluate this multiple times while the pattern is playing to see the tempo evolve

Pdef(2).stop // evaluate this to stop the Pdef, and then evaluate ~clock.tempo again to verify that it is set to whatever value it stopped at
```
/*




# SoundSources


## Parameters Common to Most/All SoundSources

/*

*/

## Playing Samples:

/*

*/

## Synthesizer Modules:

/*

*/

## Routing Modules:

/*

*/




# InstanceEffects

# GlobalEffects



This may not be a complete list of parameter names.
The value range for the below parameters is 0.0 to 1.0 unless otherwise indicated.

snd:	Sample folder or synth name.
num:	Which sample in a folder, from zero up to the amount of files in that folder and then wraps back around.
pan:	Pans the sound.
shp:	Waveshaping amount.
sac:	Shaping amplitude compensation.
slo:	Waveshaping low.
shi:	Waveshaping high.
sho:	Waveshaping offset.
lot:	Waveshaping low threshold.
hit:	Waveshaping high threshold.
dst:	A crunchy distortion with a lot of high harmonics.
tri:	A triode-like distortion.
amp:	Make it louder! Can go above one to lean into the limiter.
spd:	Sample playback speed, default is 1.0, negative numbers play the sample backwards, slower playback rates closer to 0
atk:	The attack time of the envelope, the envelope parameters are expressed in seconds, 1.0 here means a one second fade in time.
hld:	The hold time of the amplitude envelope.
rel:	The release time of the amplitude envelope.
crv:	Envelope curvature, swings both ways. That is to say it uses both positive and negative values, try values between -8 to 8
lpf:	Low pass filter, value range is 20 to 20000
hpf:	High pass filter, value range is 20 to 20000
bpf:	Band pass filter, value range is 20 to 20000
lpq:	Low pass filter resonance.
hpq:	High pass filter resonance.
bpq:	Band pass filter resonance.
lhf:	Low & high pass filter combo where 0.5 does nothing, 0.0 sets the lpf to 20hz and 1.0 sets the hpf to 20000
dla:	Delay amplitude.
dlf:	Delay feedback, proly best to think of 0.94 as the max sane value.
dlt:	Delay time, value range is a very low float to 16.0
rin:	Set the amplitude of the input to the reverb.
rev:	Reverb time (or room size, if we can imagine that).
dry:	Decrease the amplitude of the reverb.
bgn:	Where in the file to begin playing back the file.
end:	Where in the file to end playing back the file.
bnd:	Bend. Change playback speed of samples while running, accepts positive and negative values. Certain synths also accept bnd.
bnt:	Bend time. Accepts positive values. This value gets multiplied with the sustain key. The default is 0.2
bno:	Offset the time at which the bend begins.
bnc:	Bend curvature. Accepts positive and negative values.
lop:	How many times to loop the file, takes integers, works in consort with the envelope parameters.
cut:	Cut groups, cuts itself as well as other things in the same cut group. Rougher edges than legato in terms of sound tho so.
aux:	An auxiliary output, you can use these for different outputs or same output with different effects depending on your startup file.
rma:	Ringmodulation wet amount.
rmf:	Ringmodulation frequency.
rdf:	The ringmodulation frequency to glissando in from, which can be above or below rmf, range is 20 to 20000
rdt:	The time in seconds it takes to glissando from the ringmodulation detune frequency.
smr:	Spectral smear.
scm:	Spectral scramble.
enh:	Spectral enhance.
ocu:	Octave up.
ocd:	Octave down.
ocq:	Quarter-frequency harmonics (two octaves down).
fsh:	Frequency shift, value range goes both positive and negative, works in combination with fsm, try values -32 to 32
fsm:	Frequency shift multiplier, value range goes both positive and negative, works in combination with fsh, try values -4 to 4
hal:	A hall reverb, this is the wet parameter, or put another way, the amplitude of the reverb.
rts:	The RT60 value of the reverb. This goes from 0 to 999. That top value is approaching inifity. It is super duper long.
edf:	Early diffusion of the hal reverb.
ldf:	Late diffusion of the hal reverb.
hhp:	A high pass filter before the hal reverb. Value range is 20 to 20000.
hlp:	A low pass filter before the hal reverb. Value range is 20 to 20000.
tnh:	 Wet mix of the tanh based distortion. Unlike  other distortions this is added after synths are summed. Try a fifth through this.
tnb:	Low pass filter before the tanh based distortion.
tng:	Tanh gain stage, this makes tons of ditortion. Range is 0.0 to 999.0
tna:	Low pass filter after the tanh based distortion.
fuz:	A very raw kind of distortion. Has a built in gate. Very touch sensitive. Value range is 0 or 1. On or off.
fzv:	Fuzz value. Range is zero to infinity.
cav:	The amplitude of the cav reverb. Range is zero to infinity but will eventually hit the limiter.
cai:	The input or send into the cav reverb. Range is zero to one.
cvt:	The cav reverb time. Range is zero to one.
cvd:	The cav reverb dampening. Range is zero to one.
cvl:	The cav low pass filter after the reverb. Range is zero to one.
bit:	Roughly translates to bit rate reduction. Value range is zero to infinity. Lower values give more action.
sam:	Roughly translates to sample rate reduction. Value range is zero to infinity. Higher values give more action.


The parameters below aren't actually part of SuperClean, but are very useful
and because SuperClean is running inside SuperCollider, we can use them.

dur:        The duration between events, range is a float above zero to infity, zero is infinitely fast, so, you mos def never want to do that.
midinote:   0 to 127. 60 is default. Interestingly accepts floats which allows for microtonality
freq:       When working with synths and we want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000
scale:      Choose scale, for example: Scale.harmonicMinor, add a tuning there like this: Scale.harmonicMinor.tuning_(Tuning.sept1)
degree:     Negative infinity to infinity really but proly there will be seven degrees in scale.
octave:     Choose the octave. Range is zero infinity really but a reasonable range is more like 1 to 6. Accepts floats which is crazy/fun
ctranspose: Chromatic transpostion. All keys on piano. Range is something like integers between -63 and 64 but depends on everything else.
mtranspose: Modal transposition of degree within a scale. Works in combination with other keys like degree and scale.
harmonic:   Multiplies the frequency determined by midinote, typically to an overtone. https://en.wikipedia.org/wiki/Overtone

stepsPerOctave has no documentation that I can find. Very little is know about this strange parameter other than that it's default is 12.
Try untoggling that key in this example:

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \fmx,
		dur: 1/8,
		pan: Pwhite(0.0, 1.0),
		degree: Pseq((0 .. 7), inf),
		stepsPerOctave: Pwhite(1, 12),
	])
).play
)


There are some notable exceptions in this list of keys that provide convenient
calculation of frequency when compared to the equivalent list in SuperCollider.
This is because these keys have been reconstructed inside the custom event type
that is SuperClean. There are some workarounds. You can use ctranspose as a dropin
replacement for root. If you add 60 to a midinote value you get the equivalent
to note. If you add a fraction like for example 0.5 at the end of a midinote
calculation you get the equivalent of detune.

legato :     Like a variable soft cut dependent on dur where 1 is equal to dur. This is unlike cut in that it only affects itself.
sustain:     Adds sustain by changing the timescale of the envelope. Can turn a drum into a drone. Value range is a float above 0 to infinity.


In the \fmx synth definition the envelope segments are expressed in
percentages. e4 through to e1 tell you how far into the note value that the
envelope should have reached it’s maximum level after the attack time, after
which the release time begins immediately. So an e1 value of 0.01 will yield a
1% duration for the attack and a 99% duration for the release. c4 through to c1
denote the curvature of the envelope segments. hr is the harmonicity ratio of
the operator. mi means modulation index, which is the modulation amount by
which that oscillator will modulate the next. The last oscillator (e1) doesn’t
have a modulation index value because it isn’t modulating anything else. The
first oscillator modulates itself with the fb parameter. SuperCollider has an
uncanny knack for delivering such clean synthesis, owing to negligible round
off errors in the calculation of waveforms at the lowest level. This becomes
especially important for me where modulation indexes are concerned. Without
this level of detail, FM can otherwise easily become a very round about way for
me to make white noise.

freq:
hr1:
hr2:
hr3:
hr4:
fdb:
mi2:
mi3:
mi4:
en1:
en2:
en3:
en4:
cu1:
cu2:
cu3:
cu4:


In the \drm synth definition you can change the tuning of the drum with tun.
Strange wrapping and nonlinear range. Start trying values around 1.  The fed
parameter controls the amount of feedback inside the oscillator. Value range is
0 to a lot where 0 is a sine, the higher up you go the noisier. The pew
parameter controls the space blaster to metal kickdrum morph. Lower values are
more space blaster like. Higher values sound tighter.

tun:
fed:
pew:


The \hat synth definition is a noise source through a filter and an envelope.
You can use tun in a weird way to provide some variation on the frequency.
bnd sweeps the filter.

tun:
bnd:


The \clp synth definition uses a full frequency range impulse that is run through
a narrow band-pass filter and a fast envelope for the clap's noise burst, and a
high-pass filter to provide some body at the onset of the hit.  Set the volume of
the body by using the tha parameter (thump amp), and control it's initial pitchbend
amount with bdy, and use bdt to set how long it takes to get there.  Thump's tuning
can also be adjusted relative to the main clap sound by usingthe tho key. Control the
character of the sound with the srp (sharpness) parameter, which allows you to tune
the claps, sounding maybe a bit more "real" somewhere between 0.3 and 0.35, and more
synthetic elsewhere. The srq parameter, the band-pass filter's resonance allows you to
dial in the tone a bit more. The dmp key controls a final LPF that acts a dampener for the sound.

srp: (0, 1) parameter range
srq: (0, 1) parameter range
bdy: -(0, 1)+ parameter range
tha: (0, 1)+ parameter range
tho: (0.01, 1)+ parameter range
dmp: (20, 20000) parameter range


The \kps synth definition Karplus-Strong physical modeling of a vibrating string,
using a delay line (CombL) excited by an intial pulse (Impulse)
freq or midinote controls the frequency. bnd is used for a pitch glide. Value range is -1 to 1.

freq:
bnd:
bnt:
bno:
bnc:


The \sin synth definition is a sine wave oscillator. It accepts freq and midinote
and parameters like those. It can also let you control the initial phase with the
iph parameter. This might not be very exciting since it is a sine wave and frequency
is either 100% phase cancelled out or not at all.

freq:
iph:
bnd:
bnt:
bno:
bnc:


The \saw synth definition is a saw wave oscillator. It accepts freq and midinote
and parameters like those. It can also let you control the initial phase with the
iph parameter. This might  potentially be very cool because you can then partially
phase out another saw wave. You can also control the width of the saw wave with
the wid parameter.

freq:
iph:
wid:
bnd:
bnt:
bno:
bnc:

The \sqr synth definition is a square wave oscillator. Same thing as above for the
parameters.

freq:
wid:
bnd:
bnt:
bno:
bnc:


The \dfd synth definition is a transient excited filter, the filter itself is noisy and can selfoscillate
den: the density of transients.
res: the resonance of the filter. 1 is a tremendous sweetspot. Range is 0 to 1.01.
typ: the type of filter where 0.0 is low pass and 1.0 is high pass.
nsl: the noise level. Range is 0 to infinity. Go easy here, as a little goes a very long way.

freq:
den:
res:
typ:
nsl:


The \bow synth definition is a digital wave guide physical model of a bowed instrument.
frc: Force.
pos: Position.
bpr: Bow pressure.

freq:
frc:
pos:
bpr:


The \ixa synth definition is a kind of phase distortion based synth.
It has a lot of potential for timbral unfolding after initiation.
It builds on the work of Nathan Ho. Read more here: https://nathan.ho.name/posts/ixa-synthesis/
bes: slopeBelow speed.
ber: slopeBelow range.
abs: slopeAbove speed.
abr: slopeAbove range.
ths: threshold speed.
thr: threshold range.

freq:
bnd:
bnt:
bno:
bnc:


// Here's an example using most of the parameters from above all together in one wild mess
(
Pdef(0,
    Pseed(10,
        Pbind(*[
            type: Prand([\cln, \r], inf),
            dur: 1/Prand([1, 2, 4,8], inf),
            snd: Pxrand([\fmx, \drm, \hat, \dfd, \sin, \saw, \sqr],inf),
            scale: Scale.harmonicMinor.tuning_(Tuning.sept1),
            pan: Pwhite(0.0, 1.0),
            shp: Pexprand(1, 2) - 1,
            sac: 0.999,
            slo: Pexprand(1, 2) - 1,
            shi: 1 - Pexprand(0.01, 1),
            sho: Pwhite(0.0, 1.0),
            lot: Pexprand(1 ,2)-1,
            hit: Pexprand(1, 2)-1,
            dst: Pexprand(1, 2)-1,
            tri: Pexprand(1, 2)-1,
            amp: Pexprand(1, 1.5)-1,
            atk: Pexprand(1, 2)-1,
            hld: Pexprand(1, 4),
            rel: Pexprand(1, 2)-1,
            crv: Pexprand(1, 9)-1,
            lpf: 20000 - Pexprand(2000, 20000),
            hpf: Pexprand(20, 200),
            bpf: Pwhite(20, 200),
            lpq: Pwhite(0.0, 1.0),
            bpq: Pexprand(1, 2) - 1,
            hpq: Pexprand(1, 2) - 1,
            lhf: Pwhite(0.0, 1.0),
            rps: Pexprand(1, 9),
            dla: Pdup(Pkey(\rps), (1 - Pexprand(0.1, 1.0))),
            dlf: Pdup(Pkey(\rps), (0.9 - Pexprand(0.00001, 0.9))),
            dlt: Pdup(Pkey(\rps), Pwhite(1.0, 16.0).round(1/2)),
            dlt: 16.0,
            hr1: Pdup(Pkey(\rps) - Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            hr2: Pdup(Pkey(\rps) + Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            hr3: Pdup(Pkey(\rps) - Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            hr4: Pdup(Pkey(\rps) + Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            fdb: Pexprand(0.0001, 100.0),
            mi2: Pdup(Pkey(\rps) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
            mi3: Pdup(Pkey(\rps) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
            mi4: Pdup(Pkey(\rps) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
            en1: Pdup(Pkey(\rps) + Pwhite(0, 7), Pexprand(0.0001, 0.555)),
            en2: Pdup(Pkey(\rps) + Pwhite(0, 7), Pkey(\en1) * Pexprand(0.2, 0.666)),
            en3: Pdup(Pkey(\rps) + Pwhite(0, 7), Pkey(\en1) * Pkey(\en2) / Pexprand(0.3, 0.777)),
            en4: Pdup(Pkey(\rps) + Pwhite(0, 7), Pkey(\en1) * Pkey(\en2) / Pkey(\en3) * Pexprand(0.4, 0.888)),
            cu1: Pdup(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            cu2: Pdup(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            cu3: Pdup(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            cu4: Pdup(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            ada: Pexprand(0.00000000000000000000000000000000000000000000001, 10.1),
            adr: Pkey(\dur) + (Pexprand(0.000001, 10.0)),
            wid: (Pexprand(0.01, 0.5)),
            iph: Pwhite(0.0, 1.0),
            rin: Pwhite(0.0, 1.0),
            rev: Pwhite(0.0, 1.0),
            dry: Pwhite(0.0, 1.0),
            bgn: Pexprand(1, 1.25) - 1,
            end: 1 - Pexprand(0.75, 1.0),
            bnd: Pwhite(-1.5, 1.5),
            lop: Pexprand(1, 5) - 1,
            aux: Pwhite(0, 1),
            rma: Pwhite(0.0, 1.0),
            rmf: Pwhite(20, 200),
            rdf: Pwhite(20, 200),
            rdt: Pexprand(1, 2) - 1,
            smr: Pwrand([0, 1], [32, 1].normalizeSum, inf),
            scm: Pwrand([0,1],[16,1].normalizeSum,inf),
            enh: Pwrand([0,1],[8,1].normalizeSum,inf),
            cav: Pwrand([0,0.5],[4,1].normalizeSum,inf),
            degree: Pdup(Pkey(\rps),Pxrand((0..7),inf)),
            octave: Pdup(Pkey(\rps),Pxrand((2..6),inf)),
            sustain: Pexprand(1,4).round(0.25),
            legato: Pexprand(1,4).round,
        ])
    )
).play(quant:1);

Pdef(1,
    Pseed(1,
        Pbind(*[
            type: Prand([\cln, \r], inf),
            dur: 1/Prand([1, 2, 4,8], inf),
            snd: \mmd,
            num: Pwhite(0, 12),
            legato: Pexprand(1,4).round,
            pan: Pwhite(0.0, 1.0),
            amp: Pexprand(1,3)-1,
            spd: Prand([1/4,1/2,1,2,4,-0.25,-0.5,-2,-4],inf),
            rel: Pexprand(1,4)-1,
            crv: Pexprand(0.01,4)-4,
            cut: Pwhite(0,1),
            aux: Pwhite(0,1),
        ])
    )
).play(quant:1);

Pdef(2,
    Pseed(2,
        Pbind(*[
            type: \cln,
            snd: \add,
            freq: Pn(Plazy {
                var lo = (1 .. 11).choose;
                var hi = (1 .. 11).choose;
                50 * (lo..hi);
            }),
            ada: Pexprand(0.00000000000000000000000000000000000000000000001,10.1),
            adr: Pkey(\dur)+(Pexprand(0.000001,10.0)),
            dur: Prand([16, 32], inf) / Pwrand([1, 2, 4, 8],[8, 4, 2, 1].normalizeSum, inf),
            amp: Pexprand(0.5,1.0),
			legato: 1,
        ])
    )
).play(quant:1);

Pdef(3,
    Pseed(63,
        Pbind(*[
            type: Pwrand([\cln, \r],[1,0].normalizeSum, inf),
            snd: \kps,
            \freq, Pn(Plazy {
                var lo = (1, 3 .. 11).wchoose((11, 9 .. 1));
                var hi = (1, 3 .. 11).choose;
                50 * Pseq((lo..hi), 1);
            }).trace,
            dur: 1/Pdup(Pwhite(5,11),Pwhite(5,11)),
            sustain: Pdup(Pwhite(16,32),Pexprand(1/32,1)),
            crv: 8,
            amp: Pexprand(0.5,1.5),
            lhf: Pseg([0.0,0.5,0.0],Pexprand(1,40),\lin,inf),
            stretch: Pseg(Pseq([1,Pexprand(1/4,16),1],inf),Pexprand(1,20),\lin,inf),
            legato: 4,
        ])
    )
).play(quant:1);
)


```
