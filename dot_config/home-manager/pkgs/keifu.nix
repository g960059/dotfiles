{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, libgit2
, git
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "keifu";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "trasta298";
    repo = "keifu";
    rev = "v${version}";
    hash = "sha256-jMUhg3irMzTPV0TKaZU6/jiKCMAQLF0SJTUJdub4IA4=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ openssl libgit2 git ]
    ++ lib.optionals stdenv.isDarwin [ darwin.libiconv ];

  # 依存が vendoring しないように寄せる（必要なら）
  OPENSSL_NO_VENDOR = 1;
  LIBGIT2_SYS_USE_PKG_CONFIG = 1;

  meta = with lib; {
    description = "Git genealogy, untangled. A TUI for navigating commit graphs";
    homepage = "https://github.com/trasta298/keifu";
    license = licenses.mit;
    mainProgram = "keifu";
    platforms = platforms.unix;
  };
}

