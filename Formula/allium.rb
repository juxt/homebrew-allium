class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  url "https://github.com/juxt/allium-tools/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "87bb20e7dc550a61b47efca4bf410bf0c1b73b9471de2169077cf5ec9912e6d4"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/allium")
  end

  test do
    (testpath/"test.allium").write("entity Empty {}\n")
    assert_match "1 file(s) checked, no issues found",
                 shell_output("#{bin}/allium check #{testpath}/test.allium 2>&1")
  end
end
