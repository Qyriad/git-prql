{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		crane = {
			url = "github:ipetkov/crane";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {
		self,
		nixpkgs,
		flake-utils,
		crane,
	}: flake-utils.lib.eachDefaultSystem (system: let

		pkgs = import nixpkgs { inherit system; };
		craneLib = import crane { inherit pkgs; };

		git-prql = import ./default.nix { inherit pkgs craneLib; };

	in {
		packages = {
			default = git-prql;
			inherit git-prql;
		};

		devShells.default = pkgs.callPackage git-prql.mkDevShell { self = git-prql; };

		checks = {
			package = self.packages.${system}.git-prql;
			clippy = self.packages.${system}.git-prql.clippy;
			devShell = self.packages.${system}.git-prql.default;
		};
	});
}
