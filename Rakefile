#!/usr/bin/ruby -Ku
# Rakefile
# 

task :default => [:mfc] do end

desc "create mfc data"
task :mfc => ["config.hcopy", "script.hcopy"] do
  sh "HCopy -C config.hcopy -S script.hcopy"
end

desc "create proto_hmm"
task :proto_hmm do 
  File.open("hai.hmm", "w") do |outfile|
    outfile.puts <<DOC
~o <VecSize> 39 <MFCC_O_D_A>
~h "hai"
<BeginHMM>
<NumStates> 5
DOC
    [2, 3, 4].each do |state|
      outfile.puts "<State> #{state}"
      outfile.puts "<Mean> 39"
      39.times { outfile.print "0.0 " }
      outfile.puts
      outfile.puts "<Variance> 39"
      39.times { outfile.print "1.0 " }
      outfile.puts
    end
    outfile.puts "<TransP> 5"
    1.upto(5) { |i| outfile.print((i == 1)? "1.0 " : "0.0 ") }
    outfile.puts
    2.upto(4) do |j|
      1.upto(5) { |i| outfile.print((i == j or i == j+1)? "0.5 " : "0.0 ") }
      outfile.puts
    end
    1.upto(5) { outfile.print "0.0 " }
    outfile.puts
    outfile.puts "<EndHMM>"
  end
end
