{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, libgit2
, openssl
, zlib
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "keifu";
  version = "0.2.2"; # GitHub Releases の Latest が v0.2.2 (2026-01-15) :contentReference[oaicite:3]{index=3}

  src = fetchFromGitHub {
    owner = "trasta298";
    repo  = "keifu";
    rev   = "v${version}";
    hash  = lib.fakeSha256; # ← まずはこれでOK（後で置き換える）
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [ pkg-config ];

  # git2/libgit2 系を踏むことが多いので、darwin も含めて無難に入れておく
  buildInputs =
    [ libgit2 openssl zlib ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.libiconv
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
      darwin.apple_sdk.frameworks.CoreFoundation
    ];

  # libgit2 を system からリンクさせる（vendored を避けやすい）
  env.LIBGIT2_SYS_USE_PKG_CONFIG = "1";

  meta = with lib; {
    description = "TUI tool to visualize Git commit graphs";
    homepage = "https://github.com/trasta298/keifu";
    license = licenses.mit;
    mainProgram = "keifu";
    platforms = platforms.darwin;
  };
}

