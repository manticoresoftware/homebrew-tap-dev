require_relative 'manticore_helper'
require 'hardware'
require "fileutils"

class ManticoreExecutorDev < Formula
  desc "Custom built PHP to run misc scripts of Manticore"
  homepage "https://github.com/manticoresoftware/executor"
  license "PHP-3.01"

  arch = Hardware::CPU.arch
  base_url = 'https://repo.manticoresearch.com/repository/manticoresearch_macos/dev/'
  fetched_info = ManticoreHelper.fetch_version_and_url(
    'manticore-executor',
    base_url,
    /(manticore-executor_)(\d+\.\d+\.\d+)(\-)(\d+\-)([\w]+)(_macos_#{arch}\.tar\.gz)/
  )

  version fetched_info[:version]
  url fetched_info[:url]
  sha256 fetched_info[:sha256]

  depends_on "openssl"
  depends_on "zstd"
  depends_on "oniguruma"
  depends_on "librdkafka"

  def install
    bin.install "manticore-executor" => "manticore-executor"
  end

  test do
    system "#{bin}/manticore-executor", "--version"
  end
end
