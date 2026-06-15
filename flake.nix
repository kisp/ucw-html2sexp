{
  description = "ucw-html2sexp flake";

  # nixos-26.05 (SBCL 2.6.4) - matches the kucw/pauldist ecosystem.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  inputs.pauldist-nix-importer = {
    url = "github:kisp/pauldist-nix-importer";
    flake = false;
  };
  # html2sexp is not on pauldist yet, so build it from source (the documented
  # "build from source for unreleased packages" pattern). Named *-src so it does
  # not shadow the lisp package "html2sexp" inside the `with selfLisp; [...]`
  # dependency lists below.
  inputs.html2sexp-src = {
    url = "github:kisp/html2sexp";
    flake = false;
  };

  outputs =
    { self, nixpkgs, pauldist-nix-importer, html2sexp-src }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      src =
        let
          patterns = ''
            *
            !*.asd
            !*.lisp
            !*.lisp-expr
            !wwwroot/
            !wwwroot/**
            !test/
            !test/**
          '';
        in
        pkgs.nix-gitignore.gitignoreSourcePure patterns ./.;

      sbcl' = pkgs.sbcl.withOverrides (
        selfLisp: superLisp:
        (pkgs.callPackage "${pauldist-nix-importer}/pauldist.nix" {
          lisp = pkgs.sbcl;
          self = selfLisp;
        })
        // {
          # kisp/arnesi call/cc fork: required to build arnesi (a transitive dep
          # via kucw / kucw-yaclml) on SBCL >= 2.4.3.
          arnesi = superLisp.arnesi.overrideAttrs (old: {
            version = "kisp-fix-sbcl-2.4.3-lambda-var";
            src = pkgs.fetchFromGitHub {
              owner = "kisp";
              repo = "arnesi";
              rev = "6de4d85b820461b6c760ce2b3404fd82b413b817";
              hash = "sha256-rDvzjwqVTFC8t+hW8VADYYL/inHOSPzSumcq61qt8YY=";
            };
          });

          html2sexp = pkgs.sbcl.buildASDFSystem {
            pname = "html2sexp";
            version = "master";
            src = html2sexp-src;
            systems = [ "html2sexp" ];
            lispLibs = with selfLisp; [
              alexandria
              cl-ppcre
              cxml-stp
              cl-html5-parser
              cl-html5-parser-cxml
              cl-who
              cl-markup
              kucw-yaclml
            ];
          };

          ucw-html2sexp = pkgs.sbcl.buildASDFSystem {
            pname = "ucw-html2sexp";
            version = "master";
            inherit src;
            systems = [ "ucw-html2sexp" ];
            lispLibs = with selfLisp; [
              kucw
              ucw-apps-sprotte-common
              ucw-github-auth
              html2sexp
            ];
          };

          ucw-html2sexp-test = pkgs.sbcl.buildASDFSystem {
            pname = "ucw-html2sexp-test";
            version = "master";
            inherit src;
            systems = [ "ucw-html2sexp-test" ];
            lispLibs = with selfLisp; [
              ucw-html2sexp
              html2sexp
              myam
            ];
          };
        }
      );

      lib = sbcl'.withPackages (ps: [ ps.ucw-html2sexp ]);
      libTest = sbcl'.withPackages (ps: [ ps.ucw-html2sexp ps.ucw-html2sexp-test ]);
    in
    {
      packages.${system} = {
        default = lib;
        ucw-html2sexp = lib;
      };

      checks.${system} = {
        # nix flake check builds checks.* (packages.* are only evaluated), so
        # build the app system here as the compile gate.
        build = lib;

        # Run the myam unit tests (the h2s-unfold document-unwrapping logic).
        tests = pkgs.runCommand "ucw-html2sexp-tests" { } ''
          ${libTest}/bin/sbcl --non-interactive \
            --eval '(require "asdf")' \
            --eval '(asdf:load-system :ucw-html2sexp-test)' \
            --eval '(uiop:quit (if (funcall (read-from-string "myam:run!") :ucw-html2sexp-test) 0 1))'
          touch $out
        '';
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
