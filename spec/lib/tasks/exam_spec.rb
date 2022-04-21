require 'spec_helper'

describe Rake::Task do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require("exam", [Rails.root.join("lib/tasks")])

    Rake::Task.define_task(:environment)
  end

  describe "rake exam:init" do
    let(:template_path) { Rails.root.join("env.yml.sample") }
    let(:markdown_files) {
      %w( exam_masters_question.md
          exam_masters_description.md
          option_masters_sentence_1.md
          option_masters_sentence_2.md
          option_masters_sentence_3.md
          option_masters_sentence_4.md
        )
    }
    let(:default) {
      { 'exam_type' => 'silver', 'answer' => nil }
    }

    before do
      FileUtils.rm_rf(template_path)
      allow(YAML).to receive(:load_file).and_return(yaml_to_hash(Rails.root.join("lib/tasks/config/env.yml.sample")))
    end

    after do
      FileUtils.rm_rf(template_path)
      @rake['exam:init'].reenable
    end

    subject { @rake['exam:init'].invoke }

    describe 'syntax of env.yml.sample' do
      it "is located at Rails root" do
        subject
        expect(File.exists?(template_path)).to be_truthy
      end

      it "includes 'markdown' key" do
        subject
        expect(yaml_to_hash(template_path)).to have_key('markdown')
      end

      it "includes markdown files" do
        subject
        expect(yaml_to_hash(template_path)['markdown'].sort).to eq(markdown_files.sort)
      end

      it "includes 'default' key" do
        subject
        expect(yaml_to_hash(template_path)).to have_key('default')
      end

      it "includes default values" do
        subject
        expect(yaml_to_hash(template_path)['default']).to eq(default)
      end
    end
  end

  describe "rake exam:deploy" do
  end
end
