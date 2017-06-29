#!/bin/ruby

curl = `curl -s https://prometheus.io/download/ | \
  grep '<tr data-os="linux" data-arch="amd64">' -A 6 | \
  grep -E 'tar\.gz\|checksum' | \
  grep -E -o '>[^<>]\+<' | \
  sed -e 's/<//g' -e 's/>//g'`

lines = curl.lines.map(&:chomp)

result = {}
name = nil
lines.each do |l|
  if l.include?('tar.gz')
    split = l.split('-')
    name = split.first
    result[name] = { 'install?' => false, 'version' => split[1][0..-7] }
  else
    result[name]['sha'] = l
  end
end

str = result.map do |k, v|
  subkeys = v.map do |sk, sv|
    if [true, false].include?(sv)
      "    '#{sk}' => #{sv}"
    else
      "    '#{sk}' => '#{sv}'"
    end
  end
  "  '#{k}' => {\n#{subkeys.join(",\n")}\n  }"
end.join(",\n")

puts str
