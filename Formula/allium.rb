class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  version "3.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-apple-darwin.tar.gz"
      sha256 "33d277a9c42a9202809d324394c37276a4329b8b5f3c5d64a503257a529d83b0"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-apple-darwin.tar.gz"
      sha256 "496fae790154c03183bc512236c4f240cc97f1b19c77e7fd56a2d976f1399cbb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "056038e90984c18b63480c0f404d9279e80d6f8ea083643f12585c5da379e6a5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f1ad15cb2d6700a73f2a9971ddc83f0c125c3696bd987243778a9ef9e9f5c7dc"
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
