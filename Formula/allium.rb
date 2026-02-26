class Allium < Formula
  desc "Checker and parser for the Allium specification language"
  homepage "https://github.com/juxt/allium-tools"
  url "https://github.com/juxt/allium-tools/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "27d3f9c6974fec78a754a8030987b7b08092aca807f5d1023426411eede4e778"
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
