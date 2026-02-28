class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  version "0.1.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-apple-darwin.tar.gz"
      sha256 "5e4a7516a0876fbe4026402711ed6e54d361b60d883ce34759caa225c8dc0976"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-apple-darwin.tar.gz"
      sha256 "e185f499bf1e420c02399440277937cf4fa40156ccb6fae405499f62e730cd54"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "356111be151f275a887dae01601c3489b49afb32820e6f96cb5370234f5bbad5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "1b1dd32e47f14b8693fe004efc488ec1ee7dee20d42c9f2599eaf592baad8332"
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
