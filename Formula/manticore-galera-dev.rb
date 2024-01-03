require_relative 'manticore_helper'
require 'hardware'

class ManticoreGaleraDev < Formula
  desc "Galera Library (Manticore's fork)"
  homepage "https://github.com/manticoresoftware/galera"
  license "GPL-2.0"

  arch = Hardware::CPU.arch
  base_url = 'https://repo.manticoresearch.com/repository/manticoresearch_macos/dev/'
  fetched_info = ManticoreHelper.fetch_version_and_url(
    'manticore-galera',
    base_url,
    /(manticore-galera-)(\d+\.\d+)(-Darwin-osx11\.6-#{arch}\.tar\.gz)/
  )

  version fetched_info[:version]
  url fetched_info[:url]
  sha256 fetched_info[:sha256]

  def install
    arch = Hardware::CPU.arch
    (share/"manticore/modules").mkpath

    if arch == :x86_64
      # For x86_64 architecture
      share.install "usr/local/share/manticore/modules/libgalera_manticore.so" => "manticore/modules/libgalera_manticore.so"
    elsif arch == :arm64
      # For arm64 architecture
      share.install "opt/homebrew/share/manticore/modules/libgalera_manticore.so" => "manticore/modules/libgalera_manticore.so"
    end
  end

  test do
    dir = share
    output = shell_output("file #{dir}/manticore/modules/libgalera_manticore.so")
    assert_match "64-bit", output
  end
end
