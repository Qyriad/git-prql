{
	lib,
	craneLib,
	stdenv,
	libiconv,
}: let

	inherit (stdenv) hostPlatform;

	# Make craneLib respect stdenv.
	craneLib' = craneLib.overrideScope (final: prev: {
		mkCargoDerivation = prev.mkCargoDerivation.override { inherit stdenv; };
	});

	commonArgs = {

		strictDeps = true;
		__structuredAttrs = true;

		src = lib.fileset.toSource {
			root = ./.;
			fileset =	lib.fileset.unions [
				./src
				./Cargo.toml
				./Cargo.lock
			];

		};

		buildInputs = lib.optionals hostPlatform.isDarwin [
			libiconv
		];
	};

	cargoArtifacts = craneLib'.buildDepsOnly commonArgs;

in craneLib'.buildPackage (commonArgs // {

	inherit cargoArtifacts;

	passthru.mkDevShell = {
		self,
		rust-analyzer,
	}: craneLib.devShell {
		inherit cargoArtifacts;
		inputsFrom = [ self ];
		packages = [ rust-analyzer ];
	};

	passthru.clippy = craneLib'.cargoClippy (commonArgs // {
		inherit cargoArtifacts;
	});

	meta = {
		homepage = "https://github.com/Qyriad/git-prql";
		description = "Query and transform Git objects with PRQL";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.all;
		mainProgram = "git-prql";
	};
})

