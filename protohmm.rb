#!/usr/bin/ruby -Ku

def protohmm(name, dir, num_states, vec_size)
  File.open("#{dir}/#{name}", "w") do |outfile|
    outfile.puts <<DOC
~o <VecSize> #{vec_size} <MFCC_D_A_0>
~h "#{name}"
<BeginHMM>
<NumStates> #{num_states}
DOC
    2.upto(num_states-1).each do |state|
      outfile.puts "<State> #{state}"
      outfile.puts "<Mean> #{vec_size}"
      vec_size.times { outfile.print "0.0 " }
      outfile.puts
      outfile.puts "<Variance> #{vec_size}"
      vec_size.times { outfile.print "1.0 " }
      outfile.puts
    end
    outfile.puts "<TransP> #{num_states}"
    1.upto(num_states) { |i| outfile.print((i == 1)? "1.0 " : "0.0 ") }
    outfile.puts
    2.upto(num_states-1) do |j|
      1.upto(num_states) do |i| 
        outfile.print((i == j or i == j+1)? "0.5 " : "0.0 ") 
      end
      outfile.puts
    end
    1.upto(num_states) { outfile.print "0.0 " }
    outfile.puts
    outfile.puts "<EndHMM>"
  end
end
