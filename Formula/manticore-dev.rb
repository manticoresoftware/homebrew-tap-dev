require_relative 'manticore_helper'
require 'hardware'

class ManticoreDev < Formula
  desc "Open source database for search"
  homepage "https://manticoresearch.com"
  license "GPL-3.0"

  arch = Hardware::CPU.arch
  base_url = 'https://repo.manticoresearch.com/repository/manticoresearch_macos/dev/'
  fetched_info = ManticoreHelper.fetch_version_and_url(
    'manticoresearch',
    base_url,
    /(manticore-)(\d+\.\d+\.\d+)(\-)(\d+-)([\w]+)(-osx11\.6-#{arch}\.tar\.gz)/
  )

  version fetched_info[:version]
  url fetched_info[:url]
  sha256 fetched_info[:sha256]

  depends_on "brotli"
  depends_on "curl"
  depends_on "libiconv"
  depends_on "librdkafka"
  depends_on "libzip"
  depends_on "oniguruma"
  depends_on "openssl@3"
  depends_on "zstd"

  conflicts_with "sphinx", because: "Manticore Search is a fork of Sphinxsearch"
  conflicts_with "manticoresoftware/tap-dev/manticore-backup-dev", because: "manticore-dev now ships the backup tool"
  conflicts_with "manticoresoftware/tap-dev/manticore-buddy-dev", because: "manticore-dev now ships Manticore Buddy"
  conflicts_with "manticoresoftware/tap-dev/manticore-columnar-lib-dev", because: "manticore-dev now ships the columnar libraries"
  conflicts_with "manticoresoftware/tap-dev/manticore-executor-dev", because: "manticore-dev now ships manticore-executor"
  conflicts_with "manticoresoftware/tap-dev/manticore-galera-dev", because: "manticore-dev now ships the Galera library"
  conflicts_with "manticoresoftware/tap-dev/manticore-icudata-dev", because: "manticore-dev now ships ICU data"
  conflicts_with "manticoresoftware/tap-dev/manticore-language-packs", because: "manticore-dev now ships the language packs"
  conflicts_with "manticoresoftware/tap-dev/manticore-load-dev", because: "manticore-dev now ships manticore-load"

  def install
    bin.install Dir["bin/*"]
    man1.install Dir["share/man/man1/*.1"]
    doc.install Dir["share/doc/manticore/*"]
    ln_s "/usr/share/zoneinfo", "share/manticore/tzdata"
    share.install "share/manticore"
    bin.install_symlink share/"manticore/modules/manticore-buddy/bin/manticore-buddy"
    ln_s share/"manticore/modules/lib_manticore_knn_embeddings.dylib",
         share/"manticore/modules/lib_manticore_knn_embeddings.so"
    include.install "include/manticore"
    etc.install "etc/manticoresearch"
  end

  def post_install
    (var/"run/manticore").mkpath
    (var/"log/manticore").mkpath
    (var/"manticore").mkpath
  end

  service do
    run [opt_bin/"searchd", "--config", etc/"manticoresearch/manticore.conf", "--nodetach"]
    environment_variables PATH: std_service_path_env
    keep_alive false
    working_dir HOMEBREW_PREFIX
  end

  test do
    assert_predicate bin/"manticore-backup", :exist?
    assert_predicate bin/"manticore-buddy", :exist?
    assert_predicate share/"manticore/icu/icudt65l.dat", :exist?
    assert_predicate share/"manticore/modules/lib_manticore_knn_embeddings.so", :symlink?
    (testpath/"manticore.conf").write <<~EOS
      searchd {
        pid_file = searchd.pid
        binlog_path=#
      }
    EOS
    pid = fork do
      exec bin/"searchd", "--config", testpath/"manticore.conf"
    end
  ensure
    Process.kill(9, pid)
    Process.wait(pid)
  end

  def caveats; <<~EOS
    If you're facing an issue with "too many open files", you may need to adjust your
    system's maxfiles limit. You can do this by executing the following command:

    sudo launchctl limit maxfiles 16384 65536

    Bear in mind, this will only establish the limit for the duration of your current
    login session. If you want this adjustment to be permanent, you'll need to modify
    your system's launchd configuration.
    EOS
  end

end
