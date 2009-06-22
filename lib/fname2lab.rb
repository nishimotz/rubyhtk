#!/usr/bin/ruby -Ku

def fname2lab_wd
  Dir.glob("_mfcc/*.mfc").sort.each_with_index do |f,i|
    name = f.split(/\//)[-1].gsub(/\.mfc/, '')
    File.open("_label_wd/#{name}.lab", "w") do |outfile|
      name.split(/_/)[-1].split(//)[0..-2].each do |d|
        if d == 'Z'
          outfile.puts "ZERO"
        else
          outfile.puts %w(OH ONE TWO THREE FOUR FIVE SIX SEVEN EIGHT NINE)[d.to_i]
        end
      end
    end
  end
end

def fname2lab_ph
  Dir.glob("_mfcc/*.mfc").sort.each_with_index do |f,i|
    name = f.split(/\//)[-1].gsub(/\.mfc/, '')
    File.open("_label_ph/#{name}.lab", "w") do |outfile|
      outfile.puts "sil"
      name.split(/_/)[-1].split(//)[0..-2].each do |d|
        if d == 'Z'
          outfile.puts "zero"
        else
          outfile.puts %w(oh one two three four five six seven eight nine)[d.to_i]
        end
      end
      outfile.puts "sil"
    end
  end
end
