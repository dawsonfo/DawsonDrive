NetAddr.langPort;

(


// instantiate CtkProtoNotes
~myPlayBufPNotes = CtkProtoNotes.new;  // protoNote dict for playing soundfiles


// -------------------------
// add synthDefs

~myPlayBufPNotes.add(

	/*
	Enveloped stereo PlayBuf
	*/
	SynthDef.new(
		\dxarts46x_stereoPlayBuf,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
			loop = 0, bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var playBufSig;
            var panSig;
            var outSig;

            // vars for control
			var numChannels = 2; // <-- stereo buffer - must be set in the UGen graph function!
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum) * rate, loop: loop);

			// apply -linen envelope
			// ... reuse playBufSig var
			// NOTE: we could have just passed ampEnvSig to the level arg of Balance2
			playBufSig = playBufSig;

			// stereo imager
			panSig = Balance2.ar(playBufSig[0], playBufSig[1], pos);  // Balance2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	),
	SynthDef('reverb', { |in, out = 0|
		var src;
		src = In.ar(in, 2);
		Out.ar(out, FreeVerb2.ar(src[0], src[1], 0.7, 0.7, 0.2))
	})
);

~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(2));

~server.waitForBoot({
	~buffers = PathName(Document.current.dir +/+ "sounds/").files.collect{ |pathName, inc|
		CtkBuffer(pathName.fullPath).load
	};

	~rateSpec = ControlSpec(0.25,4, 'exp');
		~panSpec = ControlSpec(-45,45, 'lin');


		~audioBuss = CtkAudio.play(2, server: ~server);


			~buffer = ~buffers.choose;
		~start = 0.0;

	~note = ~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start
		//duration: ~buffer.duration
	)
	.dur_(~buffer.duration)
	.bufnum_(~buffer)
		.outBus_(~audioBuss)
	.loop_(1)
	.play;


	~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail').in_(~audioBuss).play;


	~iPhone = NetAddr("192.168.0.72", 9000);

    // respond to the first fader on page 1
    ~freq = OSCFunc({ |msg, time, addr, recPort|
		~note.rate_(~rateSpec.map(msg[1]))
	}, '/1/faderA', ~iPhone);

    // respond to the first fader on page 1
    ~pan = OSCFunc({ |msg, time, addr, recPort|
		~note.pan_(~panSpec.map(msg[1]))
    }, '/1/faderB', ~iPhone);




});



)

~reverbNote.free;

NetAddr.langPort