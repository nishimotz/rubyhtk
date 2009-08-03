#!/usr/bin/ruby -Ku

class Evaluation 
  def self.mixup_train(train_data, label)
    models = []
    models << Model.first_train(train_data, label)
    while models.last.num_mixes < TARGET_NUM_MIXES
      models << models.last.mixup_train(train_data, label)
    end
    File.open("_hmm_last", "w") do |f|
      f.puts models.last.dir
    end
  end

  def self.hvite(eval_data, recout)
    last = open("_hmm_last").read.chomp
    Model.new(last).vite(eval_data, recout)
  end

  def self.hresults(mlf, out)
    system "HResults -f -L _label_wd config/models #{mlf} > #{out}"
  end
end
