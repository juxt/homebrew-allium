class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  version "0.1.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-apple-darwin.tar.gz"
      sha256 "213c4c2eaf9400b3768de6feadb874484cbd02c1fa66f693fb45148a87ee41e4"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-apple-darwin.tar.gz"
      sha256 "ea63b41736071b273ccc97c20a8605e2066da52685a71356a3c49d816c1ad9e9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "52ba4342aef63e6dde3904611142ccd03214925317e5f9fb5779ddcfa469d587"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0fcd7b61f1816c2cfeaaac7eeb89f02a188fa492160bdde1667e3c627ecb6ff0"
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
