require_relative 'manticore_helper'

class ManticoreLoadDev < Formula
    desc "Manticore Load Emulator"
    homepage "https://github.com/manticoresoftware/manticoresearch-load"
    license "MIT"
  
    base_url = 'https://repo.manticoresearch.com/repository/manticoresearch_macos/dev/'
    fetched_info = ManticoreHelper.fetch_version_and_url(
      'manticore-load',
      base_url,
      /(manticore-load_)(\d+\.\d+\.\d+)(\+)(\d+-)([\w]+)(-dev\.tar\.gz)/
    )
  
    version fetched_info[:version]
    url fetched_info[:url]
    sha256 fetched_info[:sha256]  

    def install
      # Install the binary
      bin.install "manticore-load"
  
      # Create target directory
      (share/"manticore/modules/manticore-load").mkpath
  
      # Install all files from src directory
      Dir["src/*"].each do |file|
        # Use cp_r instead of install to preserve directory structure
        cp_r file, share/"manticore/modules/manticore-load"
      end
    end
  
    test do
      assert_predicate share/"manticore/modules/manticore-load/configuration.php", :exist?
      assert_predicate bin/"manticore-load", :exist?
    end
  end