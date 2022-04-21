require 'spec_helper'

describe User do
  describe 'Relation' do
    let(:user) { create(:user) }
    let(:exam_histories) { create_pair(:exam_history, user: user) }

    it 'has many exam_history' do
      expect(user.exam_histories).to match_array exam_histories
    end
  end

  describe '.create_with_omniauth' do
    subject { described_class.create_with_omniauth(auth) }

    context 'valid auth values' do
      let(:auth) do
        {
          'provider' => 'provider',
          'uid' => 'uid',
          'info' => { 'nickname' => 'nickname', 'image' => 'image' },
          'credentials' => { 'token' => 'token' }
        }
      end

      it 'can create user' do
        expect { subject }.to change { described_class.count }.from(0).to(1)
      end

      shared_examples 'create with argument value' do |column, argment, registed_value|
        let(:auth) { argment }

        before do
          auth['info'] = { } unless auth['info']
          auth['credentials'] = { } unless auth['credentials']
        end

        it column do
          expect(subject.send(column.to_sym)).to eq registed_value
        end
      end

      it_behaves_like 'create with argument value',
                      :provider,
                      { 'provider' => 'target provider' },
                      'target provider'
      it_behaves_like 'create with argument value',
                      :uid,
                      { 'uid' => 'target uid' },
                      'target uid'
      it_behaves_like 'create with argument value',
                      :name,
                      { 'info' => { 'nickname' => 'target nickname' } },
                      'target nickname'
      it_behaves_like 'create with argument value',
                      :image,
                      { 'info' => { 'image' => 'target image' } },
                      'target image'
      it_behaves_like 'create with argument value',
                      :oauth_token,
                      { 'credentials' => { 'token' => 'target token' } },
                      'target token'
      it_behaves_like 'create with argument value', :best_gold_score, { }, 0
      it_behaves_like 'create with argument value', :best_silver_score, { }, 0
      it_behaves_like 'create with argument value', :continuous_times, { }, 0
    end

    context 'invalid auth values' do
      let(:auth) { }

      it 'exception occurs' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#history_owner?' do
    subject { user.history_owner?(exam_history) }

    let(:user) { create(:user) }
    let(:exam_history) { create(:exam_history, user: target_user) }

    context 'history owner' do
      let(:target_user) { user }
      it { is_expected.to be_truthy }
    end

    context 'not history owner' do
      let(:target_user) { create(:user) }
      it { is_expected.to be_falsey }
    end
  end

  describe '#update_best_score' do
    subject { user.update_best_score(exam_history) }

    let(:exam_history) { create(:exam_history, user: user, exam_type: exam_type, score: score) }

    context 'when exam type is gold' do
      let(:user) { create(:user, best_gold_score: 10) }
      let(:exam_type) { :gold }

      context 'when best score is exceed' do
        let(:score) { 11 }
        it 'best score is update' do
          expect { subject }.to change { User.find(user).best_gold_score }.from(10).to(11)
        end
      end

      context 'when best score is equal' do
        let(:score) { 10 }
        it { expect { subject }.not_to change { User.find(user).best_gold_score } }
      end

      context 'when best score is below' do
        let(:score) { 9 }
        it { expect { subject }.not_to change { User.find(user).best_gold_score } }
      end
    end

    context 'when exam type is silver' do
      let(:user) { create(:user, best_silver_score: 10) }
      let(:exam_type) { :silver }

      context 'when best score is exceed' do
        let(:score) { 11 }
        it 'best score is update' do
          expect { subject }.to change { User.find(user).best_silver_score }.from(10).to(11)
        end
      end

      context 'when best score is equal' do
        let(:score) { 10 }
        it { expect { subject }.not_to change { User.find(user).best_silver_score } }
      end

      context 'when best score is below' do
        let(:score) { 9 }
        it { expect { subject }.not_to change { User.find(user).best_silver_score } }
      end
    end

    context 'when exam type is marathon' do
      let(:user) { create(:user, best_gold_score: 10, best_silver_score: 10) }
      let(:exam_type) { :marathon }
      let(:score) { 11 }

      it { expect { subject }.not_to change { User.find(user).best_gold_score } }
      it { expect { subject }.not_to change { User.find(user).best_silver_score } }
    end
  end
end
