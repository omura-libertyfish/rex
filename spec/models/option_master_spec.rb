require 'spec_helper'

describe OptionMaster do
  describe 'Relation' do
    let(:option_master) { create(:option_master) }
    let!(:exam_master) { create(:exam_master, answer_index: [1], option_masters: [option_master]) }

    it 'belongs to exam_master' do
      expect(option_master.exam_master).to eq exam_master
    end
  end
end
