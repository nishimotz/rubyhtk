#!/usr/bin/ruby -Ku

def protohmm(dir, names, num_states, vec_size)
  names.each do |name|
    File.open("#{dir}/#{name}", "w") do |outfile|
      outfile.puts "~o <VecSize> #{vec_size} <MFCC_D_A_0>"
      outfile.puts "~h \"#{name}\""
      outfile.puts "<BeginHMM>"
      outfile.puts "<NumStates> #{num_states}"
      2.upto(num_states-1) do |state|
        outfile.puts "<State> #{state}"
        outfile.puts "<Mean> #{vec_size}"
        vec_size.times { outfile.print "0.0 " }
        outfile.puts
        outfile.puts "<Variance> #{vec_size}"
        vec_size.times { outfile.print "1.0 " }
        outfile.puts
      end
      outfile.puts "<TransP> #{num_states}"
      1.upto(num_states) { |i| outfile.print((i == 2)? "1.0 " : "0.0 ") }
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
end
