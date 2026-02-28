class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  version "0.1.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-apple-darwin.tar.gz"
      sha256 "50d4861f363d6aa19d4b736fc9e3e3a2fa4fba4ca404e9f163d83093c3dfdc26"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-apple-darwin.tar.gz"
      sha256 "83cb0eda9dda8caa2b67efc5d6b38dc5253f56b2f13e67a42ce5017d76b511ac"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "356111be151f275a887dae01601c3489b49afb32820e6f96cb5370234f5bbad5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/juxt/allium-tools/releases/download/v#{version}/allium-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0a24cd1e41d1bc5b6f1313e48ce322e5db2fa05d5bc199ffb2ea6a5c6873b828"
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
