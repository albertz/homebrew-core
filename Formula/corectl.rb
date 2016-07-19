class Corectl < Formula
  desc "CoreOS over OS X made very simple"
  homepage "https://github.com/TheNewNormal/corectl"
  head "https://github.com/TheNewNormal/corectl.git", :branch => "golang"

  stable do
    url "https://github.com/TheNewNormal/corectl/archive/v0.7.12.tar.gz"
    sha256 "fd4b5faba23dbc193c62e24d4927e51304e552eb93c708779d8b55c14dbd9c38"

    # until 0.7.13 is out
    # "trims Makefile logic so that qcow-tool doesn't ends being built twice"
    # while simplifying the whole picture we actually need this patch here
    # as otherwise Formula wouldn't build
    patch do
      url "https://github.com/TheNewNormal/corectl/commit/4b2876efe6e173a8b47d6bc6580f495d1131d772.patch"
      sha256 "dc249885e78b474eeac9be0cb1ddf2faf16f94f0f8c3c794463f5e5ef88a9245"
    end
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "6bd296ff3fe4ff00268cdce778e7852930ec96973e510fa1906038f44315bdbf" => :el_capitan
    sha256 "35763bc5793eaf857d4c6118a99c1963685b58eb5c5d9dbc41bc7cc4cc26f634" => :yosemite
  end

  depends_on "go" => :build
  depends_on "godep" => :build
  depends_on "ocaml" => :build
  depends_on "opam" => :build
  depends_on :macos => :yosemite

  def install
    ENV["GOPATH"] = buildpath

    opamroot = buildpath/"opamroot"
    opamroot.mkpath
    ENV["OPAMROOT"] = opamroot
    ENV["OPAMYES"] = "1"

    path = buildpath/"src/github.com/TheNewNormal/#{name}"
    path.install Dir["*"]

    args = []
    args << "VERSION=#{version}" if build.stable?

    cd path do
      system "opam", "init", "--no-setup"
      qcow_format_revision = build.head? ? "master" : "96db516d97b1c3ef2c7bccdac8fb6cfdcb667a04"
      system "opam", "pin", "add", "qcow-format",
        "https://github.com/mirage/ocaml-qcow.git##{qcow_format_revision}"
      system "opam", "install", "uri", "qcow-format", "ocamlfind"

      system "make", "tarball", *args

      bin.install Dir["bin/*"]

      man1.install Dir["documentation/man/*.1"]
      pkgshare.install "examples"
    end
  end

  def caveats; <<-EOS.undent
    Starting with 0.7 "corectl" has a client/server architecture. So before you
    can use the "corectl" cli, you have to start the server daemon:

    $ corectld start

    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/corectl version")
  end
end
