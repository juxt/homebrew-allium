class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  url "https://github.com/juxt/allium-tools/archive/a4cb936fc52a235c6308455ea70fa4607a67a493.tar.gz"
  version "0.1.0"
  sha256 "deace55df5b800cc34b972d06a3018acb40b9655a8c482b3f951bdc62d7cb11f"
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
