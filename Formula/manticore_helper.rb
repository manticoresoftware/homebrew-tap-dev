require 'open-uri'
require 'date'
require "digest"

module ManticoreHelper
  def self.fetch_version_and_url(formula_name, base_url, pattern)
    highest_version, highest_version_url = self.find_version_and_url(formula_name, base_url, pattern)
    url, sha256 = download_file(formula_name, highest_version_url)
    {
      version: highest_version,
      url: url,
      sha256: sha256
    }
  end

  def self.find_version_and_url(formula_name, base_url, pattern)
#    puts "Attempting to open URL: #{base_url}"

    content = URI.open(base_url).read
    versions = []

    content.scan(pattern) do |match|
      semver = match[1]
      separator = match[2]
      date = match[3]
      hash_id = match[4]

      versions << { semver: Gem::Version.new(semver), separator: separator, date: date, hash_id: hash_id, file: "#{match[0]}#{semver}#{separator}#{date}#{hash_id}#{match[5]}" }
    end

#    puts "Found versions: #{versions}"

    if versions.empty?
      raise "Could not find versions by using provided URL and pattern"
    end

    versions.sort_by! { |v| [v[:semver], v[:date]] }.reverse!

    highest_version = "#{versions.first[:semver]}#{versions.first[:separator]}#{versions.first[:date]}#{versions.first[:hash_id]}"
    highest_version_url = base_url + versions.first[:file]

#    puts "Highest version detected: #{highest_version}"
#    puts "URL for the highest version: #{highest_version_url}"

    if highest_version.nil? || highest_version_url.nil?
      raise "Could not find version or URL for '#{formula_name}' with the given pattern: #{pattern}"
    end

    [highest_version, highest_version_url]
  end

  def self.download_file(formula_name, url)
    sha256 = Digest::SHA256.new
    URI.open(url) do |remote_file|
      contents = remote_file.read
      sha256.update(contents)
    end
    [url, sha256.hexdigest]
  end
end
