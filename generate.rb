#! /usr/bin/env ruby

require 'open-uri'
require 'nkf'

data = URI.open('https://raw.githubusercontent.com/google/mozc/master/src/data/emoji/emoji_data.tsv').read
result = {}
data.each_line do |line|
    next if line =~ /^#.*/
    arr = line.split(/\t/)
    next if arr[0] == ''
    arr[6].split(/\s/).each do |yomi|
        regular_yomi = NKF.nkf('-Z0wW', yomi).downcase
        result[regular_yomi] = [] unless result[regular_yomi]
        result[regular_yomi].push arr[1]
    end
end


open('SKK-JISYO.emoji-ja.utf8', 'w') do |f|
    f << ";; skk-emoji-jisyo-ja\n"
    URI.open('LICENSE').each_line {|line| f << ";; #{line}" }
    f << ";;\n"
    f << ";;\n"
    f << ";; Original emoji_data.tsv from Mozc Project\n"
    f << ";; https://github.com/google/mozc\n"
    f << ";;\n"
    URI.open('https://raw.githubusercontent.com/google/mozc/master/LICENSE').each_line {|line| f << ";; #{line}" }
    f << ";;\n"
    f << ";; okuri-nasi entries.\n"
    f << result.sort_by(&:first).map{|k,v| "#{k} /#{v.join('/')}/"}.join("\n")
    f << "\n"
end
