/*
Project Title: projectSimplePlayBuf
Date: Wed Jan 29 13:48:27 2025

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
_main_ is where we'll organize the "main" tasks of our project.

*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


///////////////// load functions, data & synthDefs ///////////////

/*
If we haven't already, we'll want to load functions, data and synthDefs.

*/
(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;

(
(Document.current.dir +/+ "synthDefs.scd").load;

~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(2));

~server.waitForBoot({
	~buffers = PathName(Document.current.dir +/+ "sounds/").files.collect{ |pathName, inc|
		CtkBuffer(pathName.fullPath).load
	};

		~audioBuss = CtkAudio.play(1, server: ~server);

	10.do{ |i|
			~buffer = ~buffers.choose;
		~start = 0.0.rrand(10,0);

	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~buffer.duration
	)
	.dur_(~buffer.duration)
	.bufnum_(~buffer)
		.outBus_(~audioBuss)
	.play

	};

	~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail').in_(~audioBuss).play;


});

~reverbNote.free;

)




/*



///////////////// set RT/NRT environment variables ///////////////

~sampleRate = s.sampleRate.isNil.if({   // set sampleRate
	"% sampleRate is %. Try booting rt server.".format(s, s.sampleRate).warn;
}, {
	s.sampleRate.asInteger
});
~serverOptions = ServerOptions.new;
~serverOptions.numOutputBusChannels = 2;  // stereo --> 2 channels
~headerFormat = "WAV";                    // soundfile header format
~sampleFormat = "int24";                  // soundfile sample format

~outputFilePath = PathName.new(
	"%/%/_%.%".format(
		Document.current.dir,
		"sounds",
		PathName.new(Document.current.dir).fileName,
		~headerFormat.toLower
	)
);


///////////////// set scoring parameter values //////////////////

/*
create score(s)...

e.g.:

~mainScore = ...;
*/

~mainScore = CtkScore.new;  // the main score to be rendered


//////////////////////// add buffers /////////////////////////
/*
NOTE: we could write functions to do this!
*/

// 1) collect soundFiles - and instance ctkBuffers
~mySoundFiles = SoundFile.collect(Document.current.dir +/+ "sounds/*");

/*
buffers are collected into a dictionary, where the key is the soundfile name
*/
~mySFBufferDict = Dictionary.newFrom(
	~mySoundFiles.collect({ |item|
		var itemPath = item.path;
		[
			PathName.new(itemPath).fileNameWithoutExtension.replace(".", "_").asSymbol,
			CtkBuffer.playbuf(itemPath)
		]
	}).flatten
);


// 2) add buffers to score
~mySFBufferDict.do({ |item|
	~mainScore.add(item)
});


// list the keys... these are the buffers (soundfiles)!
~mySFBufferDict.keys;


//////////////////////// add note events /////////////////////////

// instance single note events to play soundfiles


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...
*/
~start = 0.0;
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, backward...

- set _rate_ to -1 to play backward
- set _loop_ to 1
*/
~start = 4.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.rate_(-1)  // <-- play backward
	.loop_(1)  // <-- need to set the loop arg to 1 (True)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_dampen_ff_Ab3_stereo

loop soundfile 4x, forward...
*/
~start = 8.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: 4.0 * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration  // <-- multiply duration by 4
	)
	.dur_(4.0 * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration)  // <-- multiply duration by 4
	.loop_(1)  // <-- need to set the loop arg to 1 (True)
	.bufnum_(~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].bufnum)
);

/*
soundfile: \Vibraphone_dampen_ff_Ab3_stereo

loop soundfile 4x, backward...
*/
~start = 13.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: 4.0 * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration  // <-- multiply duration by 4
	)
	.dur_(4.0 * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration)  // <-- multiply duration by 4
	.rate_(-1)  // <-- play backward
	.loop_(1)  // <-- need to set the loop arg to 1 (True)
	.bufnum_(~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_dampen_ff_Ab3_stereo

transpose down an octave
- set _rate_ to 0.5
- set _dur_ to 2x duration
*/

// ... let's use a variable for this
/*
NOTE: we could write a function for the job!!
*/
~octTransposition = -1.0;
~rate = 2.pow(~octTransposition);
~durFactor = ~rate.reciprocal;

~start = 18.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~durFactor * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration  // <-- multiply duration by 2
	)
	.dur_(~durFactor * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration)  // <-- multiply duration by 2
	.rate_(~rate)  // <-- multiply rate by 0.5
	.bufnum_(~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_dampen_ff_Ab3_stereo

transpose down an 2 octaves
- set _rate_ to 0.25
- set _dur_ to 4x duration
*/

// ... let's use a variable for this
/*
NOTE: we could write a function for the job!!
*/
~octTransposition = -2.0;  // reusing variables
~rate = 2.pow(~octTransposition);
~durFactor = ~rate.reciprocal;

~start = 21.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~durFactor * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration  // <-- multiply duration by 4
	)
	.dur_(~durFactor * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration)  // <-- multiply duration by 4
	.rate_(~rate)  // <-- multiply rate by 0.25
	.bufnum_(~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_dampen_ff_Ab3_stereo

mix of original transposition, 1 octave down, and 2 octaves down
*/
/*
we could score the three note instances "by hand"...
... instead, we'll use a -do loop

NOTE: we could write a function for the job!!
*/
~octTransposition = [0.0, -1.0, -2.0 ];  // reusing variables...
~rate = 2.pow(~octTransposition);  // ... rate is now an array
~durFactor = ~rate.reciprocal;  // ... as is durFactor

~start = 26.0;  // reuse start

~numNoteEvents = ~octTransposition.size;  // number of note events to create

~numNoteEvents.do({ |noteEventNum|
	~mainScore.add(
		~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
			starttime: ~start,
			duration: ~durFactor[noteEventNum] * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration
		)
		.dur_(~durFactor[noteEventNum] * ~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].duration)
		.rate_(~rate[noteEventNum])
		.bufnum_(~mySFBufferDict[\Vibraphone_dampen_ff_Ab3_stereo].bufnum)
	)
});



/*
soundfile: \Vibraphone_sustain_ff_Ab3_stereo, \Vibraphone_shortsustain_ff_Ab3_stereo

play \Vibraphone_sustain_ff_Ab3_stereo forward
play \Vibraphone_shortsustain_ff_Ab3_stereo backward
*/
~start = 30.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_sustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_sustain_ff_Ab3_stereo].duration)
	.bufnum_(~mySFBufferDict[\Vibraphone_sustain_ff_Ab3_stereo].bufnum)
);

~start = 34.0;  // reuse start
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(-9.0)  // ... better mixing...
	.riseTime_(1.5)  // ... better mixing...
	.rate_(-1)  // <-- play backward
	.loop_(1)  // <-- need to set the loop arg to 1 (True)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_bow_Ab3_stereo, \Marimba_deadstroke_ff_Ab3_stereo

play \Vibraphone_bow_Ab3_stereo backward
play \Marimba_deadstroke_ff_Ab3_stereo forward

NOTE: we're cutting off \Vibraphone_bow_Ab3_stereo
*/
~start = 38.0;  // reuse start
~bowDur = 9.5;  // should be 11.608548752834, i.e., ~mySFBufferDict[\Vibraphone_bow_Ab3_stereo].duration
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~bowDur
	)
	.dur_(~bowDur)
	.rate_(-1)  // <-- play backward
	.loop_(1)  // <-- need to set the loop arg to 1 (True)
	.bufnum_(~mySFBufferDict[\Vibraphone_bow_Ab3_stereo].bufnum)
);

~start = ~start + ~bowDur - 0.1;  // reuse start, overlap previous note event by 0.1 seconds
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Marimba_deadstroke_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Marimba_deadstroke_ff_Ab3_stereo].duration)
	.bufnum_(~mySFBufferDict[\Marimba_deadstroke_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Marimba_deadstroke_ff_Ab3_stereo, \Vibraphone_bow_Ab3_stereo

play \Marimba_deadstroke_ff_Ab3_stereo, and mix of \Vibraphone_bow_Ab3_stereo, transposed by integer ratios

*/
~start = 49.0;  // reuse start, overlap previous note event by 0.1 seconds
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Marimba_deadstroke_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Marimba_deadstroke_ff_Ab3_stereo].duration)
	.bufnum_(~mySFBufferDict[\Marimba_deadstroke_ff_Ab3_stereo].bufnum)
);


/*
NOTE:
- we could write a function to do this!!
- we could adapt function \simpleSineBell OR \simplePrismBell from assignment-2 for the job!!
*/
~numTransRatios = 10;
~rate = Array.series(~numTransRatios, 1);  // ... rate is now an array
~durFactor = ~rate.reciprocal;  // ... as is durFactor

~numTransRatios.do({ |noteEventNum|
	~mainScore.add(
		~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
			starttime: ~start,
			duration: ~durFactor[noteEventNum] * ~mySFBufferDict[\Vibraphone_bow_Ab3_stereo].duration
		)
		.dur_(~durFactor[noteEventNum] * ~mySFBufferDict[\Vibraphone_bow_Ab3_stereo].duration)
		.gain_(-6.0)  // ... better mixing...
		.rate_(~rate[noteEventNum])
		.bufnum_(~mySFBufferDict[\Vibraphone_bow_Ab3_stereo].bufnum)
	)
});


///////////////// render the main score //////////////////


// write score to sound file with the -write message, and then open with helper score function, \scoreWriteOpenSFPlayer
(
	~mainScore.write(
		path: ~outputFilePath.fullPath,
		sampleRate: ~sampleRate,
		headerFormat: ~headerFormat,
		sampleFormat: ~sampleFormat,
		options: ~serverOptions,
		action: ~myScoreFuncs[\scoreWriteOpenSFPlayer].value(~mainScore, ~outputFilePath)
	)
);

/*
NOTE:

we could synthesize and then open "by hand"...
*/
/*
(
~mainScore.write(
path: ~outputFilePath.fullPath,
sampleRate: ~sampleRate,
headerFormat: ~headerFormat,
sampleFormat: ~sampleFormat,
options: ~serverOptions,
)
);

// wait until final nextOSCPacket is posted...
"Wait until nextOSCPacket % is posted before opening SFPlayer.".format(Score.new(~mainScore.score).endTime).postln;

// ... open in SFPlayer...
SFPlayer.new(~outputFilePath.fullPath).gui;
*/


// ... when finished, free buffers...
/*
it is always good practice to free up buffers when finished!!
- if we want to continue modifying the scores, it is fine to leave the buffers loaded
*/

/*
NOTE:

If we've only used the non-realtime server, this step is not necessary.

For instance, if we've only used -write rather than -play, we don't need to free buffers.

*/
*/