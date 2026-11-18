class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  version "3.7.2"

  bottle do
    root_url "https://github.com/juxt/allium-tools/releases/download/v3.7.2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d5c43fe13663263a167a3ebc713598429bc34763c2c4fb43e77ca8160c2541fc"
  end







  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-apple-darwin.tar.gz"
      sha256 "3de3acfbc7874d92c63ce4fbb92ff4333348743471b885ed15318e9401f6fc36"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-apple-darwin.tar.gz"
      sha256 ""
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "6a21afc1347bfcdb82e566ddf696e1e0b5aa56fe4acbc3428bd29f33c00a2465"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-unknown-linux-gnu.tar.gz"
      sha256 ""
    end
  end

  def install
    bin.install "allium"
  end

  test do
    (testpath/"test.allium").write("entity Empty {}\n")
    assert_match "1 file(s) checked, no issues found",
                 shell_output("#{bin}/allium check #{testpath}/test.allium 2>&1")
  end
end
